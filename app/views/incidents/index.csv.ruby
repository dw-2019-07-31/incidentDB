require 'csv'

CSV.generate("\uFEFF") do |csv|
  csv_column_names = %w(受付日 対応者 インシデント種別 申告者部門 申告者 ホスト名 OS種別 製品名 申告内容 本格対処 対応経緯 ステータス クローズ日 備考 総対応時間)
  csv << csv_column_names
  @incidents.each do |incident|
    csv_column_values = [
      incident.reception_date,
      incident.operator,
      incident.type,
      incident.group,
      incident.username,
      incident.hostname,
      incident.os,
      incident.product,
      incident.subject,
      incident.solution,
      incident.story,
      incident.status,
      incident.close_date,
      incident.remarks,
      incident.costtime
    ]
  csv << csv_column_values
end
end
