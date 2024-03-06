/**
 * 一个计算器
 * Flex & Grid  布局
 * 展示所有的输入记录 ， = 不会计入 输入记录，直接运算得到结果
 * Back：删除最近的一次输入值，包括： 数字、. 操作符，但是不包括 = 号 ；
 * C: 清除所有数据，还原至初始状态
 * .: 当之前没有输入数字时，会自动拼接0.  ； 当前面有输入数据时，在后面增加. ，当无继续输入时将值作为整数处理，当有输入数据时，作为小数存储，当后续输入操作符时，进入操作逻辑
 * 数字： 键入后，同步显示在面板，如果前面有操作符，则运行操作符计算，如没有，则无需处理
 * 操作符： 键入后，同步显示在面板，并执行操作符逻辑计算，如果时第一次输入就是操作符，不做计算
 * =： 根据输入记录，计算得到结果。如果只有操作符，或者.（等计算表达式不成立的情况） 则报错
 * 限制：
 * 由于 IEE754 精度问题，限制当前输入有效数字不能超过16位
 */

import Calculate from '../util/Calculate'

import Constants from '../constants'

@Extend(Text) function calcText(color: ResourceColor, size: number) {
  .fontColor(color)
  .fontSize(size)
}

@Entry
@Component
struct Index {
  private historyTextSize: number = Constants.DISPLAY_TEXT_SIZE_DEFAULT
  private resultTextSize: number = Constants.DISPLAY_TEXT_SIZE_DEFAULT
  private historyScroller: Scroller = new Scroller()
  private resultScroller: Scroller = new Scroller()
  @State historyInputArr: string[] = []
  @State canShowResult: boolean = false
  @State result: string = ''
  inputVal: string = ''
  keyHandler = (key: string): void => {
    if (Constants.VAL_KEYS.includes(key) || Constants.DOT_KEY === key) {
      this.valHandler(key)
    } else {
      this.opHandler(key)
    }
    this.historyScroller.scrollEdge(Edge.Bottom)
    this.resultScroller.scrollEdge(Edge.Bottom)
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
    if (Constants.DOT_KEY === val && (~this.inputVal.indexOf(Constants.DOT_KEY))) {
      return null
    }
    if (this.inputVal === '0' && val === '0') {
      return null
    }
    let tempVal = `${this.inputVal}${val}`
    //限制输入有效数字长度，避免IEEE-754  精度问题
    this.inputVal = ~this.inputVal.indexOf(Constants.DOT_KEY) ? tempVal.slice(0, 17) : tempVal.slice(0, 16)
    if (this.historyInputArr.length) {
      const lastInputKey = this.historyInputArr[this.historyInputArr.length-1]
      if (Constants.OP_KEYS.includes(lastInputKey)) {
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
      if (Constants.CALC_KEYS.includes(op) && Constants.CALC_KEYS.includes(this.historyInputArr[this.historyInputArr.length-1])) {
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
    this.result = Calculate(this.historyInputArr)??''
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
    this.historyTextSize = Constants.DISPLAY_TEXT_SIZE_DEFAULT
    this.resultTextSize = Constants.DISPLAY_TEXT_SIZE_DEFAULT
  }

  @Styles opAreaStyle(){
    .backgroundColor('rgba(255, 255, 255, 1)')
    .borderRadius(8)
    .hoverEffect(HoverEffect.Highlight)
  }

  @Styles calcKeyStyle(){
    .borderRadius(8)
    .hoverEffect(HoverEffect.Highlight)
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
      Grid() {
        GridItem() {
          Column() {
            Row() {
              Scroll(this.historyScroller) {
                Text(this.historyInputArr.join(''))
                  .calcText(Color.Black, this.historyTextSize)
                  .textAlign(TextAlign.End)
              }
              .height('50%')
              .scrollBar(BarState.Off)
              .align(Alignment.Bottom)
            }

            Blank()
            if (this.canShowResult) {
              Row() {
                Scroll(this.resultScroller) {
                  Text(this.result)
                    .calcText(Color.Black, this.resultTextSize)
                    .textAlign(TextAlign.End)
                    .fontWeight(FontWeight.Bold)
                }
                .height('45%')
                .scrollBar(BarState.Off)
                .align(Alignment.Bottom)
              }
            }

          }
          .width('100%')
          .alignItems(HorizontalAlign.End)
        }
        .columnStart(1)
        .columnEnd(4)
        .opAreaStyle()
        .align(Alignment.End)
        .padding(8)

        ForEach(Constants.KEYS, (item: string) => {
          if (item === '=') {
            GridItem() {
              Text(item)
                .calcText(Constants.OP_TEXT_COLOR, Constants.DISPLAY_TEXT_SIZE_DEFAULT)
            }
            .rowStart(5)
            .rowEnd(6)
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
          } else if (['Back', 'C', '/', 'x', '-', '+'].includes(item)) {
            GridItem() {
              Text(item)
                .calcText(Constants.OP_TEXT_COLOR, ['-', '+'].includes(item) ? Constants.OP_TEXT_SIZE : Constants.VAL_TEXT_SIZE)
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
            GridItem() {
              Text(item)
                .calcText(Constants.VAL_TEXT_COLOR, Constants.VAL_TEXT_SIZE)
            }
            .columnStart(1)
            .columnEnd(2)
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
          else {
            GridItem() {
              Text(item)
                .calcText(Constants.VAL_TEXT_COLOR, Constants.VAL_TEXT_SIZE)
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
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsTemplate('2fr 1fr 1fr 1fr 1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)

      Text(Constants.TITLE)
        .fontColor(Constants.VAL_TEXT_COLOR)
        .fontSize(12)
        .margin({
          top: 8
        })
    }
    .backgroundColor('rgba(0, 0, 0, 1)')
    .padding(10)
    .height('100%')

  }
}