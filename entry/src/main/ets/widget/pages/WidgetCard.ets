@Extend(Text) function calcText(color: ResourceColor, size: number) {
  .fontColor(color)
  .fontSize(size)
}

@Extend(Text) function calcKeyText(color: ResourceColor, size: number) {
  .fontColor(color)
  .fontSize(size)
  .height('100%')
}

const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct WidgetCard {
  @LocalStorageProp('historyInputArr') historyInputArr: string[] = [];
  @LocalStorageProp('formId') formId: string = '0';
  @LocalStorageProp('result') result: string = '';
  readonly ABILITY_NAME: string = 'EntryAbility';
  readonly KEYS: string[] = ['C', '/', 'x', 'Back', '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '=', '0', '.']
  readonly OP_KEYS: string[] = ['Back', 'C', '/', 'x', '+', '-', '=']
  readonly CALC_KEYS: string[] = ['/', 'x', '+', '-']
  readonly VAL_KEYS: string[] = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0']
  readonly DOT_KEY: string = '.'
  readonly DISPLAY_TEXT_SIZE_DEFAULT: number = 24
  readonly DISPLAY_TEXT_SIZE_MINI: number = 12
  readonly DISPLAY_TEXT_SIZE_SHRINK_UNIT: number = 6
  readonly OP_TEXT_SIZE: number = 36
  readonly VAL_TEXT_SIZE: number = 24
  private title: string = 'Calculator Service Widget @ Harmony-张子枫'
  private opKeyTextColor: string = 'rgba(253, 132, 0, 1.00)'
  private valKeyTextColor: string = 'rgba(255, 255, 255, 1)'
  private textDisplayAreaWidth: number = 0
  @State canShowResult: boolean = false
  @State inputVal: string = ''
  @State historyTextSize: number = this.DISPLAY_TEXT_SIZE_DEFAULT
  @State resultTextSize: number = this.DISPLAY_TEXT_SIZE_DEFAULT

  //监听输入历史记录与展示结果的长度，超过展示区域，字体大小缩小8fp，最小12fp
  textSizeHandler(propName: string, width): void {
    const targetPropSize = propName === 'historyInputArr' ? 'historyTextSize' : 'resultTextSize'
    if (this.textDisplayAreaWidth < width + 20) {
      const resultSize = this[targetPropSize] - this.DISPLAY_TEXT_SIZE_SHRINK_UNIT
      this[targetPropSize] = resultSize > this.DISPLAY_TEXT_SIZE_MINI ? resultSize : this.DISPLAY_TEXT_SIZE_MINI
    }
  }

  onTextDisplayAreaChange = (oldValue: Area, newValue: Area, propName: string): void => {
    this.textSizeHandler(propName, newValue.width)
  }
  keyHandler = (key: string): void => {
    if (this.VAL_KEYS.includes(key) || this.DOT_KEY === key) {
      this.valHandler(key)
    } else {
      this.opHandler(key)
    }
  }
  backHandler = (): void => {
    //回退历史,从historyInputArr最后一项最后一个字符开始删除，删除至为空时，从数组中移除改项，重复操作
    if (this.historyInputArr.length) {
      const lastInput = this.historyInputArr[this.historyInputArr.length-1]
      if (lastInput === '') {
        this.historyInputArr.pop()
      } else {
        const backRes = lastInput.slice(0, lastInput.length - 1)
        if (backRes === '') {
          this.historyInputArr.pop()
        } else {
          this.historyInputArr[this.historyInputArr.length-1] = backRes
        }
      }
      this.inputVal = this.historyInputArr[this.historyInputArr.length-1]
    } else {
      this.inputVal = ''
    }
    this.equalHandler()
  }
  valHandler = (val: string): void => {
    if (this.DOT_KEY === val && (~this.inputVal.indexOf(this.DOT_KEY))) {
      return null
    }
    if (this.inputVal === '0' && val === '0') {
      return null
    }
    this.inputVal = `${this.inputVal}${val}`
    if (this.historyInputArr.length) {
      const lastInputKey = this.historyInputArr[this.historyInputArr.length-1]
      if (this.OP_KEYS.includes(lastInputKey)) {
        this.historyInputArr.push(this.inputVal)
      } else {
        this.historyInputArr[this.historyInputArr.length-1] = this.inputVal
      }
    } else {
      this.historyInputArr.push(this.inputVal)
    }
    //构成可执行表达式，进行运算
    if (this.historyInputArr.length < 3 || (this.historyInputArr.length < 4 && this.historyInputArr[0] === '-')) return null
    this.equalHandler()
  }
  opHandler = (op: string): void => {
    if (op === '=') {
      this.equalHandler()
    } else if (op === 'Back') {
      this.backHandler()
    } else if (op === 'C') {
      this.clearAllInfo()
    } else {
      if (op !== '-' && this.historyInputArr[0] === '-' && this.historyInputArr.length === 1) {
        return null
      }
      if (this.CALC_KEYS.includes(op) && this.CALC_KEYS.includes(this.historyInputArr[this.historyInputArr.length-1])) {
        this.historyInputArr[this.historyInputArr.length-1] = op
      } else {
        if ((op === '-' && this.historyInputArr.length === 0) || this.historyInputArr.length) {
          this.historyInputArr.push(op)
        }
      }

      this.clearInputVal()
    }
  }
  equalHandler = (): void => {
    // 调用 UIAbility 中的能力，然后通知卡片刷新
    console.info('postCardAction to EntryAbility');
    postCardAction(this, {
      'action': 'call',
      'abilityName': this.ABILITY_NAME, // 只能跳转到当前应用下的UIAbility
      'params': {
        'method': 'calculate',
        'formId': this.formId,
        'historyInputArr': JSON.stringify(this.historyInputArr)
      }
    });
    this.canShowResult = true
  }
  clearInputVal = (): void => {
    this.inputVal = ''
  }
  clearAllInfo = (): void => {
    this.historyInputArr = []
    this.result = ''
    this.inputVal = ''
    this.canShowResult = false
    this.historyTextSize = this.DISPLAY_TEXT_SIZE_DEFAULT
    this.resultTextSize = this.DISPLAY_TEXT_SIZE_DEFAULT
  }

  @Styles opAreaStyle(){
    .backgroundColor('rgba(255, 255, 255, 1)')
    .borderRadius(8)
    .height('24.6%')
  }

  @Styles calcKeyStyle(){
    .height('12.2%')
    .borderRadius(8)
  }

  @Styles calcKeyPressStyle(){
    .backgroundColor('rgba(105, 105, 107, 1.00)')
    .opacity(0.6)
  }

  @Styles calcKeyNormalStyle(){
    .backgroundColor('rgba(105, 105, 107, 1.00)')
    .opacity(1)
  }

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      // 使用不均匀的网格完成一个简易的计算器布局
      GridRow({ gutter: 8 }) {
        GridCol({ span: 12 }) {
          Column() {
            Row() {
              Text(this.historyInputArr.join(''))
                .calcText(Color.Black, this.historyTextSize)
                .textAlign(TextAlign.End)
            }

            if (this.canShowResult) {
              Row() {
                Text(`${this.result}`)
                  .calcText(Color.Black, this.resultTextSize)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Bold)

              }
            }

          }
          .width('100%')
          .alignItems(HorizontalAlign.End)
          .id('displayArea')
        }
        .opAreaStyle()
        .align(Alignment.End)
        .padding(8)

        ForEach(this.KEYS, (item: string) => {
          if (item === '=') {
            GridCol({ span: 3 }) {
              Text(item)
                .calcKeyText(this.opKeyTextColor, this.DISPLAY_TEXT_SIZE_DEFAULT)
            }
            .calcKeyStyle()
            .stateStyles({
              normal: {
                .calcKeyNormalStyle()
              },
              pressed: {
                .calcKeyPressStyle()
              }
            })
            .height('26.6%')
            .onClick(() => this.keyHandler(item))
          } else if (['Back', 'C', '/', 'x', '-', '+'].includes(item)) {
            GridCol({ span: 3 }) {
              Text(item)
                .calcKeyText(this.opKeyTextColor, ['-', '+'].includes(item) ? this.OP_TEXT_SIZE : this.VAL_TEXT_SIZE)
            }
            .calcKeyStyle()
            .stateStyles({
              normal: {
                .calcKeyNormalStyle()
              },
              pressed: {
                .calcKeyPressStyle()
              }
            })
            .onClick(() => this.keyHandler(item))
          }
          else if (item === '0') {
            GridCol({ span: 6 }) {
              Text(item)
                .calcKeyText(this.valKeyTextColor, this.VAL_TEXT_SIZE)
            }
            .calcKeyStyle()
            .stateStyles({
              normal: {
                .calcKeyNormalStyle()
              },
              pressed: {
                .calcKeyPressStyle()
              }
            })
            .translate({
              y: '-100%'
            })
            .margin({
              top: -7
            })
            .onClick(() => this.keyHandler(item))
          }
          else if (item === '.') {
            GridCol({ span: 3 }) {
              Text(item)
                .calcKeyText(this.valKeyTextColor, this.VAL_TEXT_SIZE)
            }
            .calcKeyStyle()
            .stateStyles({
              normal: {
                .calcKeyNormalStyle()
              },
              pressed: {
                .calcKeyPressStyle()
              }
            })
            .translate({
              y: '-100%'
            })
            .margin({
              top: -7
            })
            .onClick(() => this.keyHandler(item))
          }
          else {
            GridCol({ span: 3 }) {
              Text(item)
                .calcKeyText(this.valKeyTextColor, this.VAL_TEXT_SIZE)

            }
            .calcKeyStyle()
            .stateStyles({
              normal: {
                .calcKeyNormalStyle()
              },
              pressed: {
                .calcKeyPressStyle()
              }
            })
            .onClick(() => this.keyHandler(item))
          }
        })
      }
      Text(this.title)
        .fontColor(this.valKeyTextColor)
        .fontSize(12)
        .translate({
          y: '-100%'
        })
    }
    .backgroundColor('rgba(0, 0, 0, 1)')
    .padding(10)
    .height('100%')
    .width('100%')

  }
}