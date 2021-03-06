var getNowYMD, ready;

$(document).on('turbolinks:load', function() {
  var dateFormat;
  dateFormat = 'yy-mm-dd';
  try {
    if (location.pathname.match(/new/) == null){
      return false;
    }
    if ($('.has-initial-date-picker')[0].value.length > 0) {
      console.log("DatePicker(初期値あり)を表示しました。");
      return $('.has-initial-date-picker').datepicker({
        dateFormat: dateFormat
      });
    } else {
      $('.has-initial-date-picker').datepicker();
      return $('.has-initial-date-picker').datepicker('setDate', getNowYMD(), {
        dateFormat: dateFormat
      });
    }
  } catch(error) {
    console.error("DataPicker(初期値あり)の表示に失敗しました。");
    console.error(error);
  }
});

$(document).on('turbolinks:load', function() {
  var dateFormat;
  dateFormat = 'yy-mm-dd';
  try {
    if (location.pathname.match(/filter|new|edit|analysis/) == null){
      return false;
    }
    console.log("DatePicker(初期値なし)を表示しました。");
    return $('.no-initial-date-picker').datepicker({
      dateFormat: dateFormat
    });
  } catch(error) {
    console.error("DatePicker(初期値なし)の表示に失敗しました。");
    console.error(error.message);
  }
});

getNowYMD = function() {
  var d, dt, m, result, y;
  dt = new Date;
  y = dt.getFullYear();
  m = ('00' + (dt.getMonth() + 1)).slice(-2);
  d = ('00' + dt.getDate()).slice(-2);
  result = y + '/' + m + '/' + d;
  return result;
};

// ---
// generated by coffee-script 1.9.2