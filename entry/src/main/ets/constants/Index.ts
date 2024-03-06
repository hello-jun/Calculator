export default class Constants {
  static readonly KEYS: string[] = ['C', '/', 'x', 'Back', '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '=', '0', '.']
  static readonly OP_KEYS: string[] = ['Back', 'C', '/', 'x', '+', '-', '=']
  static readonly CALC_KEYS: string[] = ['/', 'x', '+', '-']
  static readonly VAL_KEYS: string[] = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0']
  static readonly DOT_KEY: string = '.'
  static readonly DISPLAY_TEXT_SIZE_DEFAULT: number = 28
  static readonly DISPLAY_TEXT_SIZE_MINI: number = 12
  static readonly DISPLAY_TEXT_SIZE_SHRINK_UNIT: number = 8
  static readonly OP_TEXT_SIZE: number = 36
  static readonly OP_TEXT_COLOR: string = 'rgba(253, 132, 0, 1.00)'
  static readonly VAL_TEXT_SIZE: number = 24
  static readonly VAL_TEXT_COLOR: string = 'rgba(255, 255, 255, 1)'
  static readonly TITLE: string = 'Calculator @ Harmony-张子枫'
}