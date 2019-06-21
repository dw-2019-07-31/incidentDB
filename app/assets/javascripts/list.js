$(document).on('turbolinks:load', function(){
  if (location.pathname.match(/filter/) == null && location.pathname != "/"){
    return false;
  }
  const tblData = document.getElementById("tbl");
  try {
    for (var i=0; i<tblData.rows.length; ++i){
      const status = tblData.rows[i].cells[8].innerHTML;
      if ( status == "対応中" ){
        tblData.rows[i].style.backgroundColor = 'yellow';
      }
    }
    console.log("list.js成功")
  }catch(error){
    console.error("list.jsでエラー");
    console.error(error);
  };
});

function return_head() {
  scrollTo(0,0);
};

// $(document).on('turbolinks:load', function(){
//   // navbarの高さを取得する
// var height = $('.navbar').height();
//   // bodyのpaddingにnavbarんぼ高さを設定する
//   $('tbody').css('padding-top','200px'); 
// // });

// $(function() {
//   $('#tablefix').tablefix({width: 500, height: 200, fixRows: 2, fixCols: 2});
// });