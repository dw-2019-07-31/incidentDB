class Incident < ApplicationRecord
    self.inheritance_column = :_type_disabled # typeというカラム名がRailsで予約されているけど、使いたいので、この行を追加

    #carriewavesで使う用
    mount_uploaders :avatars, AvatarUploader
    serialize :avatars, JSON # SQliteを使うときは、この行が必要らしい。

    #バリデーションの定義
    #空でないこと
    validates :type, :reception_date, :subject, :status, :operator, presence: true
    #ステータスがクローズのとき空でないこと
    validates :close_date, :costtime, :solution, presence: true, if: :closed?

    #数値であること
    validates :costtime, numericality: true, if: :closed?

    def closed?
        status == "クローズ"
    end

end