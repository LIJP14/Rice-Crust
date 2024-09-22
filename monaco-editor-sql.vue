<template>
  <div
    class="editor-box"
    :class="{'full-screen': fullscreen, 'has-tools': showTools}"
  >
    <div class="editor-tools" v-if="showTools">
      <div class="tools-item" v-for="item in toolsLayout" :key="item">
        <template v-if="item === tools_layout[0]">
          <el-button
            type="text"
            @click="fullscreen = !fullscreen"
            style="width: 40px;"
          >
            <svg-icon v-if="!fullscreen" icon-class="full-screen" class="full-screen-icon"></svg-icon>
            <svg-icon v-else icon-class="full-screen-exit" class="full-screen-exit-icon"></svg-icon>
          </el-button>
        </template>

        <template v-else-if="item === tools_layout[1]">
          <el-button
            type="text"
            @click="onRun"
          >
            <svg-icon
              icon-class="execute"
            ></svg-icon>执行
          </el-button>
        </template>

        <template v-else-if="item === tools_layout[2]">
          <el-button
            type="text"
            @click="onStop"
          >
            <svg-icon
              icon-class="stop-program"
              style="font-size: 13px;"
            ></svg-icon>停止
          </el-button>
        </template>

        <template v-else-if="item === tools_layout[3]">
          <el-button
            type="text"
            @click="onFormat"
          >
            <svg-icon
              icon-class="format-sql"
              style="font-size: 13px;"
            ></svg-icon>格式化
          </el-button>
        </template>

        <template v-else-if="item === tools_layout[4]">
          <el-button
            type="text"
            @click="onSave"
          >
            <svg-icon
              icon-class="save-sql"
              style="font-size: 15px;"
            ></svg-icon>保存
          </el-button>
        </template>
      </div>

      <!-- slot -->
      <slot name="tools"></slot>
    </div>

    <div
      class="editor"
      ref="editor"
    ></div>
  </div>
</template>

<script>
import * as monaco from 'monaco-editor';
import {KeyMod, KeyCode} from 'monaco-editor';
import {language as sql_language} from 'monaco-editor/esm/vs/basic-languages/sql/sql';

import 'monaco-sql-languages/esm/languages/mysql/mysql.contribution';
import { LanguageIdEnum, setupLanguageFeatures, EntityContextType, } from 'monaco-sql-languages';

import { format } from 'sql-formatter';



const hintData = {
  database_0: ['table_dim_realtime_recharge_paycfg_range', 'table_dim_realtime_recharge_range'],
  database_1: ['table_ads_adid', 'table_ads_spec_adid_category'],
};

const languageId = LanguageIdEnum.MYSQL;
const TOOLS_LAYOUT = ['fullscreen'/*全屏*/, 'run'/*执行*/, 'stop'/*停止*/, 'format'/*格式化*/, 'save'/*保存*/];
export default {
  name: "monaco-editor-sql",
  props: {
    // 是否展示工具栏
    showTools: {
      type: Boolean,
      default: true,
    },
    // 工具栏的展示顺序
    toolsLayout: {
      type: Array,
      default () {
        return TOOLS_LAYOUT;
      }
    },
    value: {
      type: String,
      default: '',
    },
  },
  data () {
    return {
      tools_layout: TOOLS_LAYOUT,
      editor: null,

      formatProvider: null,

      fullscreen: false,

      shouldShowSqlRunnerAction: null,
    }
  },
  watch: {
    value (n) {
      if (this.editor) {
        this.setValue(n || '');
      }
    },
  },
  mounted () {
    this.init();

    // // 例：添加小组件
    // this.eg_AddContentWidget();
    //
    // // 例：添加命令
    // this.eg_AddCommand();
    //
    // // 例：注册命令
    // this.eg_RegisterCommand();
    //
    // // 例：绑定快捷键
    // this.eg_BindKey();

    // // 例：添加操作
    // this.eg_AddEditorAction();
    //
    // // 例：添加编辑器动作
    // this.eg_AddAction();

    // 例：

    // 例：

    // 例：
    // 例：
    // 例：



    



    // todo
    // onDidChangeContent

    this.editor.onContextMenu(() => {
      // setTimeout(() => {
      //   const x = this.getSelectionValue();
      //   console.log(x)
      //   this.shouldShowSqlRunnerAction.set(!!x)
      // })

      console.log('11')
    })

    this.editor.onContextMenu(() => {
      console.log('222')
    })
  },
  beforeDestroy () {
    this.editor && this.editor.dispose();
  },
  methods: {
    init () {
      // 自动补全
      this.onCompletion();
      // 格式化菜单
      this.contextMenuFormat();

      this.editor = monaco.editor.create(this.$refs.editor, {
        theme: 'vs-dark',
        language: languageId,
        /* 初始值 */
        value: this.value,
        readOnly: false,
        /* 自动布局 */
        automaticLayout: true,
        /* 阻止编辑器滚动到最后一行之外 */
        scrollBeyondLastLine: true,
        minimap: {
          enabled: false
        },
      });

      // 运行菜单
      this.contextMenuRunner();
    },
    /**
     * 自动补全功能
     */
    onCompletion () {
      const _this = this;
      setupLanguageFeatures(languageId, {
        completionItems: {
          enable: true,
          // triggerCharacters: [' ', '.', ...sql_language.keywords],
          completionService: (
            model,
            position,
            completionContext,
            suggestions, // 语法推荐信息
            entities // 当前编辑器文本的语法上下文中出现的表名、字段名等
          ) => {
            // console.log(suggestions)
            return new Promise((resolve, reject) => {
              if (!suggestions) {
                return Promise.resolve([]);
              }

              let suggestionArr = [];

              // 关键字
              const {keywords, syntax} = suggestions;
              const keywordsCompletionItems = keywords.map((kw) => ({
                label: kw,
                kind: monaco.languages.CompletionItemKind.Keyword,
                detail: 'keyword',
                sortText: '2' + kw
              }));
              suggestionArr = [...keywordsCompletionItems];


              // 数据库名、表名
              const { lineNumber, column } = position;
              const textBeforePointer = model.getValueInRange({
                startLineNumber: lineNumber,
                startColumn: 0,
                endLineNumber: lineNumber,
                endColumn: column,
              });
              const tokens = textBeforePointer.trim().split(/\s+/);
              const lastToken = tokens[tokens.length - 1]; // 获取最后一段非空字符串
              // from 关键字之后
              const isFrom = lastToken && lastToken.toUpperCase() === 'FROM';
              // 小圆点"."之后
              const isEndPoint = lastToken.endsWith('.');

              if (isFrom) { // from 关键字之后，有"数据库名称"和关键字的提示
                suggestionArr = [...keywordsCompletionItems, ..._this.getDBSuggest()];
              } else if (isEndPoint) { // 小数点前如果有匹配的数据库名称，则展示"表名称"的提示
                const tokenNoDot = lastToken.slice(0, lastToken.length - 1);
                if (hintData[tokenNoDot]) {
                  suggestionArr = [..._this.getTableSuggest(tokenNoDot)];
                }
              }

              // let syntaxCompletionItems = [];
              // syntax.forEach((item) => {
              //   if (item.syntaxContextType === EntityContextType.DATABASE || isFrom) {
              //     syntaxCompletionItems = [...syntaxCompletionItems, [...数据库提示]];
              //   }
              //   if (item.syntaxContextType === EntityContextType.TABLE || isEndPoint) {
              //     syntaxCompletionItems = [...syntaxCompletionItems, ...表名提示];
              //   }
              // });
              // suggestionArr = [...syntaxCompletionItems, ...suggestionArr]

              resolve(suggestionArr);
            });
          },

        },// completionItems

      });

      // monaco.languages.registerCompletionItemProvider(languageId, {
      //   triggerCharacters: ['.', ...sql_language.keywords],
      //   provideCompletionItems(
      //     model/*: editor.IReadOnlyModel*/,
      //     position/*: Position*/,
      //     context/*: languages.CompletionContext*/,
      //     token/*: CancellationToken*/
      //   ) {
      //     let suggestions = [];
      //     const { lineNumber, column } = position;
      //     const textBeforePointer = model.getValueInRange({
      //       startLineNumber: lineNumber,
      //       startColumn: 0,
      //       endLineNumber: lineNumber,
      //       endColumn: column,
      //     });
      //     const tokens = textBeforePointer.trim().split(/\s+/)
      //     const lastToken = tokens[tokens.length - 1] // 获取最后一段非空字符串
      //     if (lastToken.endsWith('.')) {
      //       const tokenNoDot = lastToken.slice(0, lastToken.length - 1)
      //       if (Object.keys(hintData).includes(tokenNoDot)) {
      //         suggestions = [..._this.getTableSuggest(tokenNoDot)];
      //       }
      //     } else if (lastToken === '.') {
      //       suggestions = []
      //     } else {
      //       suggestions = [..._this.getDBSuggest(), ..._this.getSQLSuggest()]
      //     }
      //     return {
      //       suggestions,
      //     };
      //   }
      // });
    },
    /**
     * 获取 SQL 语法提示
     */
    getSQLSuggest() {
      return sql_language.keywords.map((key) => ({
        label: key,
        kind: monaco.languages.CompletionItemKind.Enum,
        insertText: key,
      }));
    },
    /**
     * 获取"数据库名称"提示
     */
    getDBSuggest() {
      // {
      //   label,
      //   kind,
      //   tags?,
      //   detail?,
      //   documentation?,
      //   sortText?,
      //   filterText?,
      //   preselect?,
      //   insertText,
      //   insertTextRules?,
      //   range,
      //   commitCharacters?,
      //   additionalTextEdits?,
      //   command?:
      // }
      return Object.keys(hintData).map((key) => ({
        label: key,
        kind: monaco.languages.CompletionItemKind.Constant,
        detail: 'database',
        insertText: key,
      }));
    },
    /**
     * 获取"表名称"提示：1、如果参数为 true，则返回全部表名 2、如果参数为数据库名称，则返回对应的表名
     * @param dbName
     * @returns {{insertText: *, kind: languages.CompletionItemKind.Constant, label: *, detail: string}[]|*[]}
     */
    getTableSuggest (dbName) {
      let tableNames = [];
      const isBoolean = typeof dbName === 'boolean';
      // 如果是布尔值并且为真
      if (isBoolean && dbName) {
        for (const key in hintData) {
          tableNames.push([...hintData]);
        }
      }

      if (!isBoolean && hintData[dbName]) {
        tableNames = hintData[dbName];
      }

      return tableNames.map((name) => ({
        label: name,
        kind: monaco.languages.CompletionItemKind.Constant,
        detail: 'table',
        insertText: name,
      }))
    },

    /**
     * 添加右键菜单-格式化
     * @returns {[{range: Range, text: *}]}
     */
    contextMenuFormat () {
      const _this = this;
      this.formatProvider = monaco.languages.registerDocumentFormattingEditProvider(languageId, {
        provideDocumentFormattingEdits(model) {
          return [{
            text: _this.onFormat(1, _this),
            range: model.getFullModelRange()
          }]
        }
      });
    },
    /**
     * 右键菜单-运行 sql 语句
     */
    contextMenuRunner () {
      // 用于控制切换该菜单键的显示
      this.shouldShowSqlRunnerAction = this.editor.createContextKey('shouldShowSqlRunnerAction', false);

      const _this = this;
      // 添加 action
      this.editor.addAction({
        // id
        id: 'sql-runner',
        // 该菜单键显示文本
        label: '运行选中SQL语句',
        // 控制该菜单键显示
        precondition: 'shouldShowSqlRunnerAction',
        // 该菜单键位置
        contextMenuGroupId: 'navigation',
        contextMenuOrder: 1.5,
        // 点击该菜单键后运行
        run: (event) => {
          console.log(event)
          const value = _this.getSelectionValue();
          if (value) {
            this.onRun(value);
          }

        }
      });
    },

    /**
     * 标记错误信息
     * @param range
     * @param type
     * @param message
     */
    markMistake(range, type, message) {
      console.log(this.editor.getModel())
      const {startLineNumber, endLineNumber, startColumn, endColumn} = range
      monaco.editor.setModelMarkers(
        this.editor.getModel(),
        'eslint',
        [{
          startLineNumber,
          endLineNumber,
          startColumn,
          endColumn,
          severity: monaco.MarkerSeverity[type], // type可以是Error,Warning,Info
          message
        }]
      )
    },
    /**
     * 清除错误信息
     */
    clearMistake() {
      monaco.editor.setModelMarkers(
        this.editor.getModel(),
        'eslint',
        []
      )
    },

    resize() {
      this.editor.layout();
    },
    setTheme() {
      monaco.editor.setTheme(''); // 'vs', 'vs-dark', 'hc-black'
    },


    /**
     * 获取选择的文本
     * @returns {string}
     */
    getSelectionValue () {
      const selection = this.editor.getSelection();
      const model = this.editor.getModel();
      return model.getValueInRange({
        startLineNumber: selection.startLineNumber,
        startColumn: selection.startColumn,
        endLineNumber: selection.endLineNumber,
        endColumn: selection.endColumn,
      });
    },
    /**
     * 获取 sql
     * @returns {string|*}
     */
    getValue () {
      if (this.editor) {
        return this.editor.getValue();
      }
      return '';
    },
    /**
     * 设置 sql
     * @param content
     */
    setValue (content) {
      if (this.editor) {
        this.editor.setValue(content);
      }
    },

    /**
     * 运行
     */
    onRun (val) {
      let value = '';
      if (val) {
        value = val;
      } else {
        value = this.getSelectionValue() || this.getValue();
      }
      this.$emit('run', value);
    },
    /**
     * 停止
     */
    onStop () {
      this.$emit('stop');
    },
    /**
     * 保存
     */
    onSave () {
      this.$emit('save', this.getValue());
    },
    /**
     * 格式化代码
     * @param needValue
     * @returns {*}
     */
    onFormat (needValue) {
      this.clearMistake();
      try {
        const a = this.editor.getValue();
        const x = format(a);
        console.log(x)
        this.setValue(format((this.editor).getValue()))
      } catch (e) {
        const {message} = e
        const list = message.split(' ')
        const line = list.indexOf('line')
        const column = list.indexOf('column')
        this.markMistake({
          startLineNumber: Number(list[line + 1]),
          endLineNumber: Number(list[line + 1]),
          startColumn: Number(list[column + 1]),
          endColumn: Number(list[column + 1])
        }, 'Error', message)
      }
      if (needValue) {
        return this.editor.getValue()
      }
    },





    /**
     * 添加小组件
     */
    eg_AddContentWidget () {
      // 创建一个新的content widget
      const div = document.createElement('div');
      div.style.width = '100px';
      div.style.height = '50px';
      div.style.background = 'rgba(255,0,0,0.3)'; // 半透明的红色背景
      div.textContent = 'Hello, Monaco!';
      const widget = {
        allowEditorOverflow: true,
        suppressMouseDown: true,
        getDomNode: () => div,
        getId: () => 'my.content.widget',
        getPosition: () => {
          return {
            preference: [1], // monaco.editor.ContentWidgetPositionPreference.ABOVE,
            position: {
              lineNumber: 4,
              column: 10
            }
          };
        }
      };
      // 将widget添加到编辑器中
      this.editor.addContentWidget(widget);
    },

    /**
     * 添加命令：用 monaco.editor 创建，所有的编辑器都会有此命令
     */
    eg_AddCommand (bool = false) {
      monaco.editor.addCommand({
        id: "command-123",
        run: (...args) => {
          console.log("执行了 command-123", args);
        },
      });

      if (bool) {
        // 触发
        this.editor.trigger(null, "command-123", { a: 100 });
      }
    },

    /**
     * 注册命令，可销毁
     */
    eg_RegisterCommand () {
      window.newCommand = monaco.editor.registerCommand('registerCommand_0', (accessor, ...args) => {
        console.log('registerCommand_0  ', accessor, args);
      });

      // 销毁
      // window.newCommand.dispose();
    },

    /**
     * 绑定快捷键
     */
    eg_BindKey () {
      // 一、先用 monaco.editor.addCommand 添加命令，再用 monaco.editor.addKeybindingRules 绑定

      // 1、自定义命令
      monaco.editor.addKeybindingRules([
        {
          keybinding: monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyH,
          command: "command-123", // 用 this.eg_AddCommand() 添加过的命令 ID
          when: "textInputFocus", // When
        },
      ]);

      // 2、绑定到现有命令
      monaco.editor.addKeybindingRules([
        {
          keybinding: monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyJ,
          command: "cursorDown", // ID
          when: "textInputFocus", // When
        },
      ]);


      // 二、用 monaco.editor.create().adCommand 绑定
      this.editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyK, () => {
        console.log('editor --- addCommand');
      });

    },

    /**
     * 向所有编辑器添加一个操作
     */
    eg_AddEditorAction () {
      monaco.editor.addEditorAction({
        id: "action123", // 唯一ID
        label: "action123", // 显示的名称
        keybindings: [
          KeyMod.chord(
            KeyMod.CtrlCmd | KeyCode.KeyM,
            KeyMod.CtrlCmd | KeyCode.KeyK
          ),
        ],   // 快捷键
        contextMenuOrder: 100, // 操作在菜单中的显示顺序
        // 指定操作应显示在上下文菜单的哪个组中 navigation表示默认组
        // 可选值 navigation | 1_modification | 9_cutcopypaste
        contextMenuGroupId: "navigation",
        run: (...args) => {
          console.log("执行了 AddEditorAction - action123", args);
        },
      });
    },

    /**
     * 添加一个编辑器动作
     */
    eg_AddAction () {
      // 用于控制切换该菜单键的显示
      window._showXContext = this.editor.createContextKey('ShowXContext', false);

      setTimeout(() => {
        window._showXContext.set(true);
      }, 5000);

      this.editor.addAction({
        id: "newAction",
        label: "newAction",
        // 该菜单键位置
        contextMenuGroupId: 'navigation',
        contextMenuOrder: 1.5,
        keybindings: [KeyMod.CtrlCmd | KeyCode.KeyA],
        // 控制该菜单键显示
        precondition: 'ShowXContext',
        run: () => {
          console.log("action");
        },
      });
    },



  },
}
</script>

<style scoped lang="scss">
.editor-box {
  position: relative;

  &.full-screen {
    position: fixed;
    left: 0;
    top: 0;
    width: 100% !important;
    height: 100% !important;
    z-index: 99999;
  }
}


.editor-tools {
  height: 32px;
  margin: 0;
  padding: 0 10px;
  overflow: hidden;
  background-color: $backgroundColorGray;
  border: 1px solid $borderColor1;
  .tools-item {
    float: left;
    line-height: 32px;
    .el-button--text {
      padding: 0 12px;
      color: $contentColor;
      &:hover {
        color: $activeColor;
      }
    }
    .full-screen-icon {
      font-size: 13px;
      margin: 0;
    }
    .full-screen-exit-icon {
      font-size: 17px;
      margin: 0;
      vertical-align: -4px;
    }
  }
}


.editor {
  height: 100%;
}
.editor-box.has-tools .editor {
  height: calc(100% - 32px);
}

</style>
