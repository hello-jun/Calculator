@Extend(Text) function calcText(color: ResourceColor, size: number) {
  .fontColor(color)
  .fontSize(size)
}

@Entry
@Component
struct Index {
  @State result: string = 'Welcome To Calculator'
  private keys: string[] = ['CE', 'C', '/', 'X', '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '=', '0', '.']
  private opKeyTextColor = 'rgba(253, 132, 0, 1.00)'
  private valKeyTextColor = 'rgba(255, 255, 255, 1)'

  @Styles opAreaStyle(){
    .backgroundColor('rgba(255, 255, 255, 1)')
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
    // 使用不均匀的网格完成一个简易的计算器布局
    Grid() {
      GridItem() {
        Text(this.result)
          .calcText(Color.Black, 28)
          .textAlign(TextAlign.End)
          .fontWeight(FontWeight.Bold)
      }
      .columnStart(1)
      .columnEnd(4)
      .calcKeyStyle()
      .opAreaStyle()
      .align(Alignment.End)
      .padding(8)

      ForEach(this.keys, (item: string) => {
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
        } else if (['CE', 'C', '/', 'X', '-', '+'].includes(item)) {
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
        }

      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('2fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(10)
    .columnsGap(10)
    .backgroundColor('rgba(0, 0, 0, 1)')
    .padding(10)
  }
}