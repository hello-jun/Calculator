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
  private title: string = 'Calculator @ Harmony-Zack'
  private opKeyTextColor: string = 'rgba(253, 132, 0, 1.00)'
  private valKeyTextColor: string = 'rgba(255, 255, 255, 1)'
  private textDisplayAreaWidth: number = 0
  @State historyInputArr: string[] = []
  @State canShowResult: boolean = false
  @State result: string = ''
  @State inputVal: string = ''
  @State historyTextSize: number = Constants.DISPLAY_TEXT_SIZE
  @State resultTextSize: number = 36

  //监听输入历史记录与展示结果的长度，超过展示区域，字体大小缩小8vp，最小12vp
  textSizeHandler(propName: string): void {

    const targetStr = propName==='historyInputArr'? this.historyInputArr.join(''):this.result
    if (this.textDisplayAreaWidth<targetStr.length){
      if (propName==='historyInputArr'){

        this.historyTextSize =
      }
    }
    this.textDisplaySize = 36 - shrinkSize < 12 ? 12 : 36 - shrinkSize
  }

  onTextDisplayAreaChange = (oldValue: Area, newValue: Area): void => {
    let displayAreaData = JSON.parse(getInspectorByKey('displayArea'))
    console.log('displayAreadata-->', JSON.stringify(displayAreaData.$attrs.size));
    console.info(`Ace: on area change, oldValue is ${JSON.stringify(oldValue)} value is ${JSON.stringify(newValue)}`)
  }
  keyHandler = (key: string): void => {
    console.log('key ---- ', key);
    if (Constants.VAL_KEYS.includes(key) || Constants.DOT_KEY === key) {
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
    this.result = Calculate(this.historyInputArr)
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
    this.textDisplaySize = 36
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
                .calcText(Color.Black, this.textDisplaySize)
                .textAlign(TextAlign.End)
            }
            .onAreaChange(this.onTextDisplayAreaChange)

            if (this.canShowResult) {
              Row() {
                Text(this.result)
                  .calcText(Color.Black, this.textDisplaySize)
                  .textAlign(TextAlign.End)
                  .fontWeight(FontWeight.Bold)

              }
              .onAreaChange(this.onTextDisplayAreaChange)
            }

          }
          .width('100%')
          .alignItems(HorizontalAlign.End)
          .id('displayArea')
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.textDisplayAreaWidth = <number> newValue.width
          })
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