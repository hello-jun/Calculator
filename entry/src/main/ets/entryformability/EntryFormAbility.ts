import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';


export default class EntryFormAbility extends FormExtensionAbility {
  delayUpdateFormId = null
  onAddForm(want) {
    // Called to return a FormBindingData object.
    let formId = want.parameters["ohos.extra.param.key.form_identity"];
    let formData = {"formId": formId};
    const data = formBindingData.createFormBindingData(formData);

    //FIX: 延时二次刷新数据,解决初次添加卡片call事件功能不正常的问题
    this.delayUpdateFormId = setTimeout(()=>{
      formProvider.updateForm(formId, data).then((data) => {
        console.info('FormAbility updateForm success.' + JSON.stringify(data));
      }).catch((error) => {
        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
      })
    }, 1500)
    return data
  }

  onCastToNormalForm(formId) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId) {
    // Called to notify the form provider to update a specified form.
  }

  onChangeFormVisibility(newStatus) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId, message) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId) {
    // Called to notify the form provider that a specified form has been destroyed.
    if (typeof this.delayUpdateFormId !=='undefined' || this.delayUpdateFormId !== null) {
      this.delayUpdateFormId && clearTimeout(this.delayUpdateFormId)
    }
  }

  onAcquireFormState(want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};