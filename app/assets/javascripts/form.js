function clearFormAll() {
  try {
    for (var i=0; i<document.forms.length; ++i) {
        clearForm(document.forms[i]);
    }
    console.log("全てのフォーム内容をリセットしました。");
  } catch(error) {
    console.error("全てのフォーム内容のリセットに失敗しました。");
    console.error(error);
  }
}

function clearForm(form) {
  for(var i=0; i<form.elements.length; ++i) {
    clearElement(form.elements[i]);
  }
}

function clearElement(element) {
  switch(element.type) {
    case "text":
    case "textarea":
    case "input":
      element.value = "";
      return;
    case "select-one":
    case "select-multiple":
      element.selectedIndex = 0;
      return;
    default:
  }
}

function ClearButton_Click(id){
  try {
    this.searchForm.elements[id].value="";
    console.log("%sのリセットに成功しました。", id);
  } catch(error) {
    console.error("%sのリセットに失敗しました。", id);
    console.error(error);
  }
}