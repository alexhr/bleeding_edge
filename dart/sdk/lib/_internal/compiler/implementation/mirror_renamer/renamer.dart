// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of mirror_renamer;

class MirrorRenamer {
  static const String MIRROR_HELPER_GET_NAME_FUNCTION = 'helperGetName';
  static const String MIRROR_HELPER_LIBRARY_NAME = '_mirror_helper';
  static const String MIRROR_HELPER_SYMBOLS_MAP_NAME = '_SYMBOLS';

  /// Maps mangled name to original name.
  Map<String, SourceString> symbols = new Map<String, SourceString>();
  /// Contains all occurrencs of MirrorSystem.getName() calls in the user code.
  List<Node> mirrorSystemGetNameNodes = <Node>[];
  /**
   *  Initialized when the placeholderCollector collects the FunctionElement
   *  backend.mirrorHelperGetNameFunction which represents the helperGetName
   *  function in _mirror_helper.
   */
  FunctionExpression mirrorHelperGetNameFunctionNode;
  VariableDefinitions mirrorHelperSymbolsMapNode;
  Compiler compiler;
  DartBackend backend;

  MirrorRenamer(this.compiler, this.backend);

  void registerStaticSend(Element element, Send node) {
  if (element == compiler.mirrorSystemGetNameFunction) {
    mirrorSystemGetNameNodes.add(node);
  }
 }

  void registerHelperElement(Element element, Node node) {
    if (element == backend.mirrorHelperGetNameFunction) {
      mirrorHelperGetNameFunctionNode = node;
    } else if (element == backend.mirrorHelperSymbolsMap) {
      mirrorHelperSymbolsMapNode = node;
    }
  }

  /**
   * Adds a toplevel node to the output containing a map from the mangled
   * to the unmangled names and replaces calls to MirrorSystem.getName()
   * with calls to the corresponding wrapper from _mirror_helper which has
   * been added during resolution. [renames] is assumed to map nodes in user
   * code to mangled names appearing in output code, and [topLevelNodes] should
   * contain all the toplevel ast nodes that will be emitted in the output.
   */
  void addRenames(Map<Node, String> renames, List<Node> topLevelNodes) {
    // Right now we only support instances of MirrorSystem.getName,
    // hence if there are no occurence of these we don't do anything.
    if (mirrorSystemGetNameNodes.isEmpty) {
      return;
    }

    Node parse(String text) {
      Token tokens = compiler.scanner.tokenize(text);
      return compiler.parser.parseCompilationUnit(tokens);
    }

    // Add toplevel map containing all renames.
    symbols = new Map<String, SourceString>();
    for (Node node in renames.keys) {
      Identifier identifier = node.asIdentifier();
      if (identifier != null) {
        symbols.putIfAbsent(renames[node], () => identifier.source);
      }
    }

    Identifier symbolsMapIdentifier =
        mirrorHelperSymbolsMapNode.definitions.nodes.head.asSend().selector;
    assert(symbolsMapIdentifier != null);
    topLevelNodes.remove(mirrorHelperSymbolsMapNode);

    StringBuffer sb = new StringBuffer(
        'const ${renames[symbolsMapIdentifier]} = const<String,SourceString>{');
    bool first = true;
    for (String mangledName in symbols.keys) {
      if (!first) {
        sb.write(',');
      } else {
        first = false;
      }
      sb.write("'$mangledName' : '");
      symbols[mangledName].printOn(sb);
      sb.write("'");
    }
    sb.write('};');
    topLevelNodes.add(parse(sb.toString()));

    // Replace calls to Mirrorsystem.getName with calls to helper function.
    mirrorSystemGetNameNodes.forEach((node) {
      renames[node.selector] = renames[mirrorHelperGetNameFunctionNode.name];
      renames[node.receiver] = '';
    });
  }
}
