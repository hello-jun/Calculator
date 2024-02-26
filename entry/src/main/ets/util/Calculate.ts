/**
 * 计算器的逻辑中，是按输入记录的顺序依次计算
 * 请无视运算符优先级
 */
import Constants from '../constants'

export default function Calculate(historyInputArr: string[]): string {
  console.log('myEval>', historyInputArr);
  //处理每一项数字，对小数进行补全操作或者取整
  let targetInputArr: string[] = []
  if (!historyInputArr.length) {
    return ''
  }
  // 处理某个值是. 或者除数是0 的错误情况
  if (~historyInputArr.indexOf('.')) {
    return '错误'
  }
  const matchDivisorZero = historyInputArr.join('').match(/\/0/g)
  const matchDivisorZeroFloat = historyInputArr.join('').match(/\/0[.]/g)
  if (matchDivisorZero) {
    if (!matchDivisorZeroFloat) {
      return '错误'
    } else {
      if (matchDivisorZero.length !== matchDivisorZeroFloat.length) {
        return '错误'
      }
    }
  }
  targetInputArr = historyInputArr.map((i: string) => {
    if (~i.indexOf('.')) {
      if (i.length > 1) {
        return String(Number.parseFloat(i))
      }
    } else return i
  })
  //如果最后一项是操作符,则忽略此项
  if (Constants.OP_KEYS.includes(targetInputArr[targetInputArr.length-1])) {
    targetInputArr.pop()
  }
  //开始计算
  const resultVal: string = targetInputArr.reduce((res: string, i,index) => {
    if (isNaN(Number.parseFloat(i))) {
      // 如果是操作符，则将其拼接，带入到下次计算
      return res = `${res}${i}`
    } else {
      const val = Number.parseFloat(i)
      if (res === '') {
        return res += i
      } else {
        //第一项是- 代表是负值，特殊处理
        if (index===1 && res === '-') {
          return res += i
        }
        //正数输入处理逻辑
        const lastVal = Number.parseFloat(res.slice(0, res.length - 1))
        const op = res.slice(res.length - 1)
        if (op === '-') {
          return `${lastVal - val}`
        } else if (op === '+') {
          return `${lastVal + val}`
        } else if (op === 'x') {
          return `${lastVal * val}`
        } else if (op === '/') {
          return `${lastVal / val}`
        }
      }
    }
  }, '')
  return resultVal
}