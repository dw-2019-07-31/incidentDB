//グラフの描画
$(document).on('turbolinks:load', function(){
  // analysis以外のページがロードされた時には、処理を実行しない。
  if (location.pathname.match(/analysis/) == null){
    return false;
  }
  //変数初期化
  try {
    let id = 'typeChart',
        chartType = 'doughnut';
    myChart = create_chart(id, chartType, gon.type, gon.type_count);
    console.log(`${id}を表示しました。`);

    id = 'termChart';
    chartType = 'bar';
    myChart = create_chart(id, chartType, gon.month, gon.month_count);
    console.log(`${id}を表示しました。`);

    id = 'usernameChart';
    chartType = 'doughnut';
    myChart = create_chart(id, chartType, gon.username, gon.username_count);
    console.log(`${id}を表示しました。`);

    id = 'costtimeChart';
    chartType = 'bar';
    myChart = create_chart(id, chartType, gon.costtime, gon.costtime_count);
    console.log(`${id}を表示しました。`);

  } catch(error) {
    console.error(`${id}の表示に失敗しました。`)
  }
  id = 'incidenttermChart';
  chartType = 'line';
  try {
    console.log(`${id}を表示しました。`);
    myChart = create_chart(id, chartType, gon.month, gon.type_month_count);
  } catch(error) {
    console.error(`${id}の表示に失敗しました。`);
    console.error(error);
  }
});

//期間指定した時の処理
function filterTerm(){
  //開始日と終了日の日付取得
  let start = document.getElementById("start-date").value,
      end = document.getElementById("end-date").value,
      targets_tbl = ["type", "username"];
  if (start > end){
    alert("期間の指定が間違ってる。やり直し");
    clearElement('start-date');
    clearElement('end-date');
    return false;
  } else if (start == "" & end == ""){
    start = '2019-01-29'
    nowDate = getNowYMD()
    end = nowDate.replace('/','-')
  }
  targets_tbl.forEach(function(target_tbl){
    get_incidents(target_tbl, start, end);
  });
};

function get_incidents(target_tbl, start, end){
  const xhr = new XMLHttpRequest(),
        chartType = 'doughnut';
  let incidents = null,
      count_results = [],
      type_results  = [],
      tblCount = 0;
  xhr.onreadystatechange = function(){
    if( this.readyState == 4 && this.status == 200 ){
      incidents = this.response;
      if( this.response ){
        //table再構成
        const tblData = document.getElementById(`${target_tbl}-tbl`);
        for (var i=0; i<tblData.rows.length; ++i){
          tblData.rows[i].cells[0].innerHTML = "";
          tblData.rows[i].cells[1].innerHTML = "";
        };
        if (!Object.keys(incidents).length){
          tblData.rows[tblCount].cells[0].innerHTML = 'データがありません';
          create_chart(`${target_tbl}Chart`, chartType, type_results, count_results);
          return
        }
        for(let type in incidents){
          type_results.push(type);
          count_results.push(incidents[type]);
          tblData.rows[tblCount].cells[0].innerHTML = type;
          tblData.rows[tblCount].cells[1].innerHTML = incidents[type];
          tblCount++;
        };
        //chartの再構成
        create_chart(`${target_tbl}Chart`, chartType, type_results, [{data: count_results}]);
      }
    } else {
      console.log("通信中");
    }
  }
  let postData = encodeURIComponent('start') + '=' + encodeURIComponent(start)
                + '&' + encodeURIComponent('end') + '=' + encodeURIComponent(end);
  xhr.open('GET',`/incidents/${target_tbl}_count?${postData}`,true);
  xhr.responseType = "json"
  xhr.send( null );
};


function create_chart(id, chartType, type_results, count_results){
  let ctx = null,
      chart = null;
  ctx = document.getElementById(`${id}`).getContext('2d');
  if (chart){
    update_chart_dataset(chart);
  }
  return chart = new Chart(ctx, {
    type: chartType,
    data: {
      labels: type_results,
      datasets: count_results
    },
    options: {
      cutoutPercentage: 60,             //円の中心をどれくらい切り取るか
      plugins: {
        colorschemes: {
          scheme: 'brewer.Paired12'     //カラー設定
        }
      }
    }
  });
};

function update_chart_dataset(chart){
  chart.data.datasets.forEach((dataset) => {
    dataset.data.pop();
  });
  chart.update();
};
