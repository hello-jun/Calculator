import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import Calculate from '../util/Calculate'

import formBindingData from '@ohos.app.form.formBindingData';
import formProvider from '@ohos.app.form.formProvider';

const CALCULATE_METHOD: string = 'calculate'

function calculateListener(data) {
  // 获取call事件中传递的所有参数
  let params = JSON.parse(data.readString())
  if (params.formId !== undefined) {
    let curFormId = params.formId;
    let historyInputArr = JSON.parse(params.historyInputArr) ;
    console.info(`UpdateForm formId: ${curFormId}, message: ${historyInputArr}`);
    let formData = {
      "result": Calculate(historyInputArr)
    };
    let formMsg = formBindingData.createFormBindingData(formData)
    formProvider.updateForm(curFormId, formMsg).then((data) => {
      console.info('updateForm success.' + JSON.stringify(data));
    }).catch((error) => {
      console.error('updateForm failed:' + JSON.stringify(error));
    })
  }
  return null;
}

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    //应用与卡片复用 Calculate 计算方法
    console.info('Want:' + JSON.stringify(want));
    try {
      this.callee.on(CALCULATE_METHOD, calculateListener)
    } catch (error) {
      console.log(`${CALCULATE_METHOD} register failed with error ${JSON.stringify(error)}`)
    }
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
