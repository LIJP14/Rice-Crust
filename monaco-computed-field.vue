<!--用法：-->
<!--&lt;!&ndash; 编辑器 &ndash;&gt;-->
<!--<monaco-computed-field-->
<!--    v-if="fnAll.length"-->
<!--    ref="refMonacoComputedField"-->
<!--    :value="monacoValue"-->
<!--    :functions="fnAll"-->
<!--    :field-list="list"-->
<!--    @change="monacoChange"-->
<!--/>-->
<!--this.$refs.refMonacoComputedField.insertContent(fn.funcCode);-->

<template>
  <div
      ref="refMonaco"
      class="editor"
      style="height: 100%;min-height: 100px;"
  ></div>
</template>


<script>
// region Dependencies
import monaco from 'monaco-editor';
// endregion Dependencies


export default {
  name: "monaco-computed-field",
  props: {
    functions: {
      type: Array,
      default () {
        return []; // [ { funcCode, funcGrammar, funcDesc }, ... ]
      }
    },
    fieldList: {
      type: Array,
      default () {
        return []; // [ { columnId, colName }, ... ]
      }
    },
    value: {
      type: String,
      default: '',
    }
  },
  data () {
    return {
      editor: null,
      myValue: '',
      disposableMonarchTokens: null,
      disposableCompletion0: null,
      disposableCompletion1: null,

      disposableValue: null,
      disposableSelection: null,



      myLanguageId: 'monaco-computed-field',
      myThemeId: 'monaco-computed-field-theme',
      myFunctions: [
        // { label: 'BI_SUM', insertText: 'BI_SUM(${1:字段})', detail: '聚合函数' },
      ],
      myFields: [
        // { name: '流量', id: 'liuliang' },
      ],
    };
  },
  watch: {
    value: function (val) {
      if (val !== this.myValue) {
        this.editor && this.editor.setValue(val);
      }

    }
  },
  mounted () {
    this.init();
    this.listenerValue();
    // this.listenerSelection();
  },
  beforeDestroy () {
    this.destroyEditor();
  },
  methods: {
    insertContent (text) {
      // 1. 获取当前的选区（Selection）
      const selection = this.editor.getSelection();

      if (selection && !selection.isEmpty()) {
        // 创建一个编辑操作（通过执行编辑命令）
        this.editor.executeEdits(`insert-${text}_${Date.now()}`, [
          {
            range: selection, // 替换范围是当前选中区域
            text: text, // 新文本
            forceMoveMarkers: true, // 强制光标跟随移动
          }
        ]);

        // 替换后取消选中，只留光标在末尾
        const lastLineLength = this.editor.getModel().getLineLength(selection.endLineNumber);
        // 只留光标在新文本末尾
        const newCursorPosition = {
          lineNumber: selection.endLineNumber,
          column: selection.startColumn + text.length,
        };
        this.editor.setPosition(newCursorPosition); // 将光标移到新文本末尾
        this.editor.focus();

        return;
      }


      // ----- 插入内容
      // 获取光标位置
      const position = this.editor.getPosition();

      // 如果插入的是函数
      const index1 = this.functions.findIndex(f => f.funcCode === text);
      const index2 = this.fieldList.findIndex(f => f.colName === text);
      if (index1 > -1) {
        const fn = this.functions[index1];

        // 执行编辑操作
        this.editor.executeEdits(`insert-${fn.funcCode}_${Date.now()}`, [{
          range: new monaco.Range(
              position.lineNumber,
              position.column,
              position.lineNumber,
              position.column, // 结束列（等于起始位置，表示插入而非替换）
          ),
          text: fn.funcGrammar, // 要插入的文本
          forceMoveMarkers: false, // 光标跟随移动
        }]);
        this.editor.setPosition({
          lineNumber: position.lineNumber,
          column: position.column + fn.funcCode.length + 1
        });
      }
      else if (index2 > -1) {
        const val = `[${text}]`;
        // 执行编辑操作
        this.editor.executeEdits(`insert-${text}_${Date.now()}`, [{
          range: new monaco.Range(
              position.lineNumber,
              position.column,
              position.lineNumber,
              position.column, // 结束列（等于起始位置，表示插入而非替换）
          ),
          text: val, // 要插入的文本
          forceMoveMarkers: true, // 光标跟随移动
        }]);

      }
      // 插入的不是函数
      else {
        // 执行编辑操作
        this.editor.executeEdits(`insert-${text}_${Date.now()}`, [{
          range: new monaco.Range(
              position.lineNumber,
              position.column,
              position.lineNumber,
              position.column, // 结束列（等于起始位置，表示插入而非替换）
          ),
          text: text, // 要插入的文本
          forceMoveMarkers: true, // 光标跟随移动
        }]);

        // const oldVal = this.editor.getValue();
        // this.editor.setValue(oldVal + text);
        //
        // this.editor.setPosition({
        //   lineNumber: position.lineNumber,
        //   // column: (oldVal + text).length + 1,
        //   column: this.editor.getModel().getLineLength(position.lineNumber) + 1,
        // });
        // this.editor.focus();
      }
      this.editor.focus();





    },


    init () {
      // 准备函数列表和字段列表
      this.onFunctions();
      this.onFields();

      // 注册自定义语言
      monaco.languages.register({ id: this.myLanguageId });

      // 语法高亮
      this.disposableMonarchTokens = monaco.languages.setMonarchTokensProvider(this.myLanguageId, {
        tokenizer: {
          root: [
            // 函数关键字
            [this.onKeywordReg(), 'keyword'],

            // 中括号变量
            [/\[[^\]]+\]/, 'variable'],

            // 数字
            [/-?\d+(\.\d+)?/, 'number'],

            // 操作符和括号
            [/[+\-*/(),]/, 'delimiter'],

            // 其他标识符
            [/[a-zA-Z_]\w*/, 'identifier'],
          ]
        }
      });

      // 定义配色主题
      monaco.editor.defineTheme(this.myThemeId, {
        base: 'vs',
        inherit: true,
        rules: [
          { token: 'keyword',   foreground: '#0000FF', fontStyle: 'bold' },
          { token: 'variable',  foreground: '098658' },
          { token: 'number',    foreground: '#098658' },
          { token: 'delimiter', foreground: '000000' },
        ],
        colors: {
          "editor.foreground": "#000000", // 字体颜色
          'editorSuggestWidget.selectedBackground': '#0985f85a', // 选中背景色
          'editorSuggestWidget.selectedForeground': '#000000', // 选中字体颜色
        },
      });

      // 创建编辑器
      this.editor = monaco.editor.create(this.$refs.refMonaco, {
        language: this.myLanguageId,
        theme: this.myThemeId,
        automaticLayout: true,
        contextmenu: false,
        folding: false, // 代码折叠
        fontSize: 14,
        lineDecorationsWidth: 0, // 行号和编辑器内容之间
        lineNumbers: 'off', // 显示行号
        minimap: { enabled: false,},
        overviewRulerBorder: false,
        scrollbar: {
          horizontalScrollbarSize: 10,
          verticalScrollbarSize: 10,

        },
        value: this.value,

      });
      // console.log(this.editor, this.editor._themeService._theme === this.editor._themeService.getColorTheme());
      // console.log(this.editor._themeService.getColorTheme());

      this.registerCompletionFunction();
      this.registerCompletionField();
    },
    /**
     * 注册函数自动补全
     */
    registerCompletionFunction () {
      // 注册自动补全：函数
      this.disposableCompletion0 = monaco.languages.registerCompletionItemProvider(this.myLanguageId, {
        triggerCharacters: ['(', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'],
        provideCompletionItems: (model, position, context) => {
          // if (context.triggerKind === monaco.languages.CompletionTriggerKind.TriggerCharacter) {
          //   if (!context.triggerCharacter.match(/^[A-Za-z(]$/)) {
          //     return { suggestions: [] };
          //   }
          // }

          // 获取光标前的字符
          const textUntil = model.getValueInRange({
            startLineNumber: position.lineNumber,
            startColumn: Math.max(1, position.column - 1),
            endLineNumber: position.lineNumber,
            endColumn: position.column
          });

          if (!(/[a-zA-Z]$/.test(textUntil))) {
            return { suggestions: [] };
          }


          // 如果刚输入的是字母或左括号，推荐函数
          const suggestions = this.myFunctions.map(f => {
            return {
              label: f.label,
              kind: monaco.languages.CompletionItemKind.Function,
              insertText: f.insertText, //  + ')',
              insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
              detail: f.detail
            };
          });
          return { suggestions: suggestions };
        }
      });
    },
    /**
     * 注册字段自动补全
     */
    registerCompletionField () {
      // 注册自动补全：字段
      this.disposableCompletion1 = monaco.languages.registerCompletionItemProvider(this.myLanguageId, {
        triggerCharacters: ['['],
        provideCompletionItems: (model, position, context) => {
          // 当用户输入 [ 时，弹出字段列表
          if (context.triggerKind === monaco.languages.CompletionTriggerKind.TriggerCharacter && context.triggerCharacter !== '[') {
            return { suggestions: [] };
          }

          // 获取光标前的字符
          const textUntil = model.getValueInRange({
            startLineNumber: position.lineNumber,
            startColumn: Math.max(1, position.column - 1),
            endLineNumber: position.lineNumber,
            endColumn: position.column
          });
          if (textUntil !== '[') {
            return { suggestions: [] };
          }

          const suggestions = this.myFields.map(f => {
            return {
              label: f.name,
              kind: monaco.languages.CompletionItemKind.Field,
              insertText: f.name + ']',
              range: {
                startLineNumber: position.lineNumber,
                startColumn: position.column,
                endLineNumber: position.lineNumber,
                endColumn: position.column
              },
              detail: '字段: ' + f.id
            };
          });
          return { suggestions: suggestions };
        }
      });

    },
    destroyEditor () {
      if (this.editor) {
        this.editor.dispose();
        this.editor = null;
      }
      if (this.disposableMonarchTokens) {
        this.disposableMonarchTokens.dispose();
        this.disposableMonarchTokens = null;
      }
      if (this.disposableCompletion0) {
        this.disposableCompletion0.dispose();
        this.disposableCompletion0 = null;
      }
      if (this.disposableCompletion1) {
        this.disposableCompletion1.dispose();
        this.disposableCompletion1 = null;
      }
      if (this.disposableValue) {
        this.disposableValue.dispose();
        this.disposableValue = null;
      }
      if (this.disposableSelection) {
        this.disposableSelection.dispose();
        this.disposableSelection = null;
      }
    },


    /**
     * 监听编辑器内容变化
     */
    listenerValue () {
      this.disposableValue = this.editor.onDidChangeModelContent((event) => {
        // 当编辑器内容发生变化时，这个回调函数会被执行
        this.myValue = this.editor.getValue();
        this.$emit('update:value', this.myValue);
        this.$emit('change', this.myValue);
      });
    },
    /**
     * 监听编辑器选区变化
     */
    listenerSelection () {
      this.disposableSelection = this.editor.onDidChangeCursorSelection((event) => {
        const selection = event.selection; // 获取当前选区信息

        console.log('选区发生变化:', selection);
        console.log('起始行:', selection.startLineNumber);
        console.log('起始列:', selection.startColumn);
        console.log('结束行:', selection.endLineNumber);
        console.log('结束列:', selection.endColumn);

        // 如果 startLineNumber === endLineNumber 且 startColumn === endColumn，表示没有实际选中（只是光标移动）
        const isTextSelected = !(selection.startLineNumber === selection.endLineNumber && selection.startColumn === selection.endColumn);

        if (isTextSelected) {
          const selectedText = this.editor.getModel().getValueInRange(selection);
          console.log('选中的文本:', selectedText);
        }

      });
    },


    /**
     * 处理函数，为'自动补全'做准备
     */
    onFunctions () {
      // "ABS(number, ...)" 转换为 "ABS(${1:number}, ${2:...})"
      function transformParams(str) {
        let index = 1;
        return str.replace(/\(([^)]*)\)/, function(match, params) {
          // 分割参数，考虑可能存在的空格
          const paramArray = params.split(',').map(param => param.trim());
          const newParams = paramArray.map(param => `${param ? '${' + index++ + ':' + param + '}' : ''}`);
          return '(' + newParams.join(', ') + ')';
        });
      }

      this.myFunctions = [];
      this.functions.forEach(f => {
        this.myFunctions.push({
          label: f.funcCode,
          insertText: transformParams(f.funcGrammar || ''),
          detail: f.funcDesc
        });
      });
    },


    /**
     * 处理字段，为'自动补全'做准备
     */
    onFields () {
      this.myFields = [];
      this.fieldList.forEach(f => {
        this.myFields.push({
          name: f.colName,
          id: f.columnId
        });
      });
    },

    /**
     *
     */
    onKeywordReg () {
      const fnNames = this.myFunctions.map(item => item.label).join('|')
      const keywordReg = new RegExp(`\\b(${fnNames})\\b`, 'g');
      return keywordReg;
    },
  }, // methods

}
</script>

<style scoped lang="scss">

// 覆盖 monaco 默认样式
.editor ::v-deep {
  // suggest 提示框的 detail 框样式
  .suggest-details-container {
    background-color: #ffffff !important;
  }

  .monaco-scrollable-element > .scrollbar > .slider {
    border-radius: 10px;
  }
}


</style>