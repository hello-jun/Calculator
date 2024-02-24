/**
 * 一个计算器
 * Flex & Grid  布局
 * 展示所有的输入记录 ， = 不会计入 输入记录，直接运算得到结果
 * Back：删除最近的一次输入值，包括： 数字、. 操作符，但是不包括 = 号 ； 并且，当输入 = 得到最终的结果后，按此键，将会清除所有数据，面板显示 0
 * C: 清除所有数据，还原至初始状态
 * .: 当之前没有输入数字时，会自动拼接0.  ； 当前面有输入数据时，在后面增加. ，当无继续输入时将值作为整数处理，当有输入数据时，作为小数存储，当后续输入操作符时，进入操作逻辑
 * 数字： 键入后，同步显示在面板，如果前面有操作符，则运行操作符计算，如没有，则无需处理
 * 操作符： 键入后，同步显示在面板，并执行操作符逻辑计算，如果时第一次输入就是操作符，不做计算
 * =： 根据输入记录，计算得到结果。如果只有操作符，或者.（等计算表达式不成立的情况） 则报错
 * @param color
 * @param size
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
  private title: string = 'Calculator @ Zack' + Calculate(['1', '-', '2', '+', '10'])
  private opKeyTextColor = 'rgba(253, 132, 0, 1.00)'
  private valKeyTextColor = 'rgba(255, 255, 255, 1)'
  private lastOp = ''
  @State historyInputArr: string[] = []
  @State lastResult: string = ''
  @State result: string = ''
  @State inputVal: string = ''
  keyHandler = (key: string): void => {
    console.log('key ---- ', key);
    if (Constants.VAL_KEYS.includes(key) || Constants.DOT_KEY === key) {
      this.valHandler(key)
    } else {
      this.opHandler(key)
    }
  }
  backHandler = (): void => {
    if (this.lastOp === '=') {
      // 等于操作后，再次按 Back 键 等同于按 C 键
      this.clearAllInfo()
    } else {
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
      }

    }
    this.equalHandler()
  }
  valHandler = (val: string): void => {
    if (Constants.DOT_KEY === val && Constants.DOT_KEY === this.inputVal) {
      return null
    }
    if (this.inputVal === '0' && val === '0') {
      return null
    }
    console.log('old this.inputVal -->', this.inputVal);
    this.inputVal = `${this.inputVal}${val}`
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
  }
  opHandler = (op: string): void => {
    if (op === '=') {
      this.equalHandler()
    } else if (op === 'Back') {
      this.backHandler()
    } else if (op === 'C') {
      this.clearAllInfo()
    } else {
      if (Constants.CALC_KEYS.includes(op) && Constants.CALC_KEYS.includes(this.historyInputArr[this.historyInputArr.length-1])) {
        this.historyInputArr[this.historyInputArr.length-1] = op
      } else {
        if ((op === '-' && this.historyInputArr.length === 0) || this.historyInputArr.length) {
          this.historyInputArr.push(op)
        }
      }

      this.clearInputVal()
    }
    this.lastOp = op
  }
  equalHandler = (): void => {
    this.result = Calculate(this.historyInputArr)
  }
  clearInputVal = (): void => {
    this.inputVal = ''
  }
  clearAllInfo = (): void => {
    this.historyInputArr = []
    this.result = ''
    this.inputVal = ''
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
              Text(this.historyInputArr.join(''))
                .calcText(Color.Black, 28)
                .textAlign(TextAlign.End)
                .fontWeight(FontWeight.Bold)
            }

            Row() {
              Text(this.result)
            }
          }
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
                .calcText(this.opKeyTextColor, 36)
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
                .calcText(this.opKeyTextColor, ['-', '+'].includes(item) ? 36 : 24)
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
                .calcText(this.valKeyTextColor, 24)
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
                .calcText(this.valKeyTextColor, 24)
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

      Text(this.title)
        .fontColor(this.valKeyTextColor)
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