<template>
  <div
    :style="{height: height}"
    class="ck-editor-container"
  >
    <ckeditor
      :value="value"
      :editor="editor"
      :config="config"
      @input="onInput"
    />
  </div>
</template>

<script>
import CKEditor from '@ckeditor/ckeditor5-vue2';

import {
  ClassicEditor,
  Alignment,
  Autoformat,
  AutoImage,
  AutoLink,
  Autosave,
  BalloonToolbar,
  BlockQuote,
  Bold,
  // Bookmark,
  Code,
  Essentials,
  FindAndReplace,
  FontBackgroundColor,
  FontColor,
  FontFamily,
  FontSize,
  GeneralHtmlSupport,
  Heading,
  Highlight,
  HorizontalLine,
  ImageBlock,
  ImageCaption,
  ImageInline,
  ImageInsert,
  ImageInsertViaUrl,
  ImageResize,
  ImageStyle,
  ImageTextAlternative,
  ImageToolbar,
  ImageUpload,
  Indent,
  IndentBlock,
  Italic,
  Link,
  LinkImage,
  List,
  ListProperties,
  // Markdown,
  MediaEmbed,
  Mention,
  PageBreak,
  Paragraph,
  PasteFromOffice,
  RemoveFormat,
  SimpleUploadAdapter,
  SpecialCharacters,
  SpecialCharactersArrows,
  SpecialCharactersCurrency,
  SpecialCharactersEssentials,
  SpecialCharactersLatin,
  SpecialCharactersMathematical,
  SpecialCharactersText,
  Strikethrough,
  Style,
  Subscript,
  Superscript,
  Table,
  TableCaption,
  TableCellProperties,
  TableColumnResize,
  TableProperties,
  TableToolbar,
  TextTransformation,
  TodoList,
  Underline
} from 'ckeditor5';

import translations from 'ckeditor5/translations/zh-cn.js';

import 'ckeditor5/ckeditor5.css';
// import 'ckeditor5/ckeditor5-content.css';

export default {
  name: "ck-editor",
  components: {
    ckeditor: CKEditor.component
  },
  props: {
    height: {
      type: String,
      default: '500px',
    },
    value: {
      type: String,
      default: ''
    },
  },
  data () {
    const LICENSE_KEY = 'GPL'; // or <YOUR_LICENSE_KEY>.

    return {
      editor: ClassicEditor,

      config: {
        toolbar: {
          items: [
            'undo',
            'redo',
            '|',
            'heading',
            // 'style',
            '|',
            'fontSize',
            // 'fontFamily',
            'fontColor',
            'fontBackgroundColor',
            '|',
            'bold',
            'italic',
            'underline',
            '|',
            'link',
            // 'insertImage', // 有下拉
            // 'insertImageViaUrl', // 直接弹框
            'insertTable',
            'highlight',
            'blockQuote',
            '|',
            'alignment',
            '|',
            'bulletedList',
            'numberedList',
            'todoList',
            'outdent',
            'indent'
          ],
          shouldNotGroupWhenFull: true
        },
        plugins: [
          Alignment,
          Autoformat,
          AutoImage,
          AutoLink,
          Autosave,
          BalloonToolbar,
          BlockQuote,
          Bold,
          // Bookmark,
          Code,
          Essentials,
          FindAndReplace,
          FontBackgroundColor,
          FontColor,
          FontFamily,
          FontSize,
          GeneralHtmlSupport,
          Heading,
          Highlight,
          HorizontalLine,
          ImageBlock,
          ImageCaption,
          ImageInline,
          ImageInsert,
          ImageInsertViaUrl,
          ImageResize,
          ImageStyle,
          ImageTextAlternative,
          ImageToolbar,
          ImageUpload,
          Indent,
          IndentBlock,
          Italic,
          Link,
          LinkImage,
          List,
          ListProperties,
          // Markdown,
          MediaEmbed,
          Mention,
          PageBreak,
          Paragraph,
          PasteFromOffice,
          RemoveFormat,
          SimpleUploadAdapter,
          SpecialCharacters,
          SpecialCharactersArrows,
          SpecialCharactersCurrency,
          SpecialCharactersEssentials,
          SpecialCharactersLatin,
          SpecialCharactersMathematical,
          SpecialCharactersText,
          Strikethrough,
          Style,
          Subscript,
          Superscript,
          Table,
          TableCaption,
          TableCellProperties,
          TableColumnResize,
          TableProperties,
          TableToolbar,
          TextTransformation,
          TodoList,
          Underline
        ],
        // balloonToolbar: ['bold', 'italic', '|', 'link', 'insertImage', '|', 'bulletedList', 'numberedList'], // 选中文本后，出现悬浮弹窗
        fontFamily: {
          supportAllValues: true
        },
        fontSize: {
          options: [12, 'default', 16, 18, 20, 24, 28, 32],
          supportAllValues: true
        },
        heading: {
          options: [
            {
              model: 'paragraph',
              title: 'Paragraph',
              class: 'ck-heading_paragraph'
            },
            {
              model: 'heading1',
              view: 'h1',
              title: 'Heading 1',
              class: 'ck-heading_heading1'
            },
            {
              model: 'heading2',
              view: 'h2',
              title: 'Heading 2',
              class: 'ck-heading_heading2'
            },
            {
              model: 'heading3',
              view: 'h3',
              title: 'Heading 3',
              class: 'ck-heading_heading3'
            },
            {
              model: 'heading4',
              view: 'h4',
              title: 'Heading 4',
              class: 'ck-heading_heading4'
            },
            {
              model: 'heading5',
              view: 'h5',
              title: 'Heading 5',
              class: 'ck-heading_heading5'
            },
            {
              model: 'heading6',
              view: 'h6',
              title: 'Heading 6',
              class: 'ck-heading_heading6'
            }
          ]
        },
        htmlSupport: {
          allow: [
            {
              name: /^.*$/,
              styles: true,
              attributes: true,
              classes: true
            }
          ]
        },
        image: {
          toolbar: [
            'toggleImageCaption',
            'imageTextAlternative',
            '|',
            'imageStyle:inline',
            'imageStyle:wrapText',
            'imageStyle:breakText',
            '|',
            'resizeImage'
          ]
        },
        initialData: '',
        language: 'zh-cn',
        // licenseKey: LICENSE_KEY,
        link: { // https://media2.hndt.com/data_02/1/3/2025/01/06/a6fd3d23108af548a17724755584879d.mp4
          addTargetToExternalLinks: true,
          defaultProtocol: 'https://',
          decorators: {
            toggleDownloadable: {
              mode: 'manual',
              label: 'Downloadable',
              attributes: {
                download: 'file'
              }
            }
          }
        },
        list: {
          properties: {
            styles: true,
            startIndex: true,
            reversed: true
          }
        },
        mention: {
          feeds: [
            {
              marker: '@',
              feed: [
                /* See: https://ckeditor.com/docs/ckeditor5/latest/features/mentions.html */
              ]
            }
          ]
        },
        menuBar: {
          isVisible: false,
          items: [
            // {
            //   menuId: 'file',
            //   label: 'File',
            //   groups: [
            //     {
            //       groupId: 'export',
            //       items: [
            //         'menuBar:exportPdf',
            //         'menuBar:exportWord'
            //       ]
            //     },
            //     {
            //       groupId: 'import',
            //       items: [
            //         'menuBar:importWord'
            //       ]
            //     },
            //     {
            //       groupId: 'revisionHistory',
            //       items: [
            //         'menuBar:revisionHistory'
            //       ]
            //     }
            //   ]
            // },
            {
              menuId: 'edit',
              label: 'Edit',
              groups: [
                {
                  groupId: 'undo',
                  items: [
                    'menuBar:undo',
                    'menuBar:redo'
                  ]
                },
                {
                  groupId: 'selectAll',
                  items: [
                    'menuBar:selectAll'
                  ]
                },
                {
                  groupId: 'findAndReplace',
                  items: [
                    'menuBar:findAndReplace'
                  ]
                }
              ]
            },
            // {
            //   menuId: 'view',
            //   label: 'View',
            //   groups: [
            //     {
            //       groupId: 'sourceEditing',
            //       items: [
            //         'menuBar:sourceEditing'
            //       ]
            //     },
            //     {
            //       groupId: 'showBlocks',
            //       items: [
            //         'menuBar:showBlocks'
            //       ]
            //     },
            //     {
            //       groupId: 'previewMergeFields',
            //       items: [
            //         'menuBar:previewMergeFields'
            //       ]
            //     },
            //     {
            //       groupId: 'restrictedEditingException',
            //       items: [
            //         'menuBar:restrictedEditingException'
            //       ]
            //     }
            //   ]
            // },
            {
              menuId: 'insert',
              label: 'Insert',
              groups: [
                {
                  groupId: 'insertMainWidgets',
                  items: [
                    // 'menuBar:insertImage',
                    'menuBar:insertImageViaUrl',
                    // 'menuBar:ckbox',
                    // 'menuBar:ckfinder',
                    'menuBar:insertTable'
                  ]
                },
                {
                  groupId: 'insertInline',
                  items: [
                    'menuBar:link',
                    // 'menuBar:bookmark',
                    // 'menuBar:comment',
                    // 'menuBar:insertMergeField'
                  ]
                },
                {
                  groupId: 'insertMinorWidgets',
                  items: [
                    // 'menuBar:mediaEmbed',
                    // 'menuBar:insertTemplate',
                    'menuBar:blockQuote',
                    // 'menuBar:codeBlock',
                    // 'menuBar:htmlEmbed'
                  ]
                },
                {
                  groupId: 'insertStructureWidgets',
                  items: [
                    'menuBar:horizontalLine',
                    'menuBar:pageBreak',
                    // 'menuBar:tableOfContents'
                  ]
                },
                // {
                //   groupId: 'restrictedEditing',
                //   items: [
                //     'menuBar:restrictedEditing'
                //   ]
                // }
              ]
            },
            {
              menuId: 'format',
              label: 'Format',
              groups: [
                {
                  groupId: 'textAndFont',
                  items: [
                    {
                      menuId: 'text',
                      label: 'Text',
                      groups: [
                        {
                          groupId: 'basicStyles',
                          items: [
                            'menuBar:bold',
                            'menuBar:italic',
                            'menuBar:underline',
                            'menuBar:strikethrough',
                            'menuBar:superscript',
                            'menuBar:subscript',
                            'menuBar:code'
                          ]
                        },
                        // {
                        //   groupId: 'textPartLanguage',
                        //   items: [
                        //     'menuBar:textPartLanguage'
                        //   ]
                        // }
                      ]
                    },
                    {
                      menuId: 'font',
                      label: 'Font',
                      groups: [
                        {
                          groupId: 'fontProperties',
                          items: [
                            'menuBar:fontSize',
                            // 'menuBar:fontFamily'
                          ]
                        },
                        {
                          groupId: 'fontColors',
                          items: [
                            'menuBar:fontColor',
                            'menuBar:fontBackgroundColor'
                          ]
                        },
                        {
                          groupId: 'highlight',
                          items: [
                            'menuBar:highlight'
                          ]
                        }
                      ]
                    },
                    'menuBar:heading'
                  ]
                },
                {
                  groupId: 'list',
                  items: [
                    'menuBar:bulletedList',
                    'menuBar:numberedList',
                    // 'menuBar:multiLevelList',
                    'menuBar:todoList'
                  ]
                },
                {
                  groupId: 'indent',
                  items: [
                    'menuBar:alignment',
                    'menuBar:indent',
                    'menuBar:outdent'
                  ]
                },
                // {
                //   groupId: 'caseChange',
                //   items: [
                //     'menuBar:caseChange'
                //   ]
                // },
                {
                  groupId: 'removeFormat',
                  items: [
                    'menuBar:removeFormat'
                  ]
                }
              ]
            },
            // {
            //   menuId: 'tools',
            //   label: 'Tools',
            //   groups: [
            //     {
            //       groupId: 'aiTools',
            //       items: [
            //         'menuBar:aiAssistant',
            //         'menuBar:aiCommands'
            //       ]
            //     },
            //     {
            //       groupId: 'tools',
            //       items: [
            //         'menuBar:trackChanges',
            //         'menuBar:commentsArchive'
            //       ]
            //     }
            //   ]
            // },
            // {
            //   menuId: 'help',
            //   label: 'Help',
            //   groups: [
            //     {
            //       groupId: 'help',
            //       items: [
            //         'menuBar:accessibilityHelp'
            //       ]
            //     }
            //   ]
            // }
          ],

        },
        placeholder: 'Type or paste your content here!',
        // style: {
        //   definitions: [
        //     {
        //       name: 'Article category',
        //       element: 'h3',
        //       classes: ['category']
        //     },
        //     {
        //       name: 'Title',
        //       element: 'h2',
        //       classes: ['document-title']
        //     },
        //     {
        //       name: 'Subtitle',
        //       element: 'h3',
        //       classes: ['document-subtitle']
        //     },
        //     {
        //       name: 'Info box',
        //       element: 'p',
        //       classes: ['info-box']
        //     },
        //     {
        //       name: 'Side quote',
        //       element: 'blockquote',
        //       classes: ['side-quote']
        //     },
        //     {
        //       name: 'Marker',
        //       element: 'span',
        //       classes: ['marker']
        //     },
        //     {
        //       name: 'Spoiler',
        //       element: 'span',
        //       classes: ['spoiler']
        //     },
        //     {
        //       name: 'Code (dark)',
        //       element: 'pre',
        //       classes: ['fancy-code', 'fancy-code-dark']
        //     },
        //     {
        //       name: 'Code (bright)',
        //       element: 'pre',
        //       classes: ['fancy-code', 'fancy-code-bright']
        //     },
        //   ]
        // },
        table: {
          contentToolbar: ['tableColumn', 'tableRow', 'mergeTableCells', 'tableProperties', 'tableCellProperties'],
          // tableProperties: {
          //   defaultProperties: {
          //     // width: '100%'
          //   }
          //
          // },
          // tableCellProperties: {
          //   defaultProperties: {
          //     // width: '100%'
          //   }
          // }
        },
        translations: [translations]
      },
    };
  },
  mounted () {
    // https://img-nos.yiyouliao.com/alph/70b864707dd74db7233478ace2fb5e36.jpeg?yiyouliao_channel=vivo_image
    // this.editor = ClassicEditor;
  },
  methods: {
    onInput (val) {
      this.$emit('input', val);
    },

  }
}
</script>

<style scoped lang="scss">

</style>

<style lang="scss">
.ck-editor-container {
  .ck-editor {
    display: flex;
    flex-direction: column;
    height: 100%;

    .ck-editor__main {
      flex: 1;
      overflow: auto;

      .ck.ck-content {
        height: 100%;

      }
    }
  }
}

.ck.ck-powered-by {
  display: none;
}
</style>