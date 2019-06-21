class IncidentsController < ApplicationController
  before_action :set_incident, only: [:show, :edit, :update, :destroy, :delete_picture, :download_picture]
  #select_tagの中身を生成する
  before_action :make_choice
  before_action :filter_by_date, only: [:analysis, :type_count, :term_count, :username_count]
  before_action :all_incident_count, only: [:analysis, :username_count]

  # GET /incidents
  # GET /incidents.json
  def index
    @incidents = Incident.all
  end

  # GET /incidents/1
  # GET /incidents/1.json
  def show
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
  end

  # GET /incidents/1/edit
  def edit
  end

  # POST /incidents
  # POST /incidents.json
  def create
    @incident = Incident.new(incident_params)
    @incident.avatars = add_avatars
    respond_to do |format|
      if @incident.save
          format.html { redirect_to :root, notice: 'インシデントを更新しました' }
          format.json { render :show, status: :created, location: @incident }
      else
        format.html { render :new }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incidents/1
  # PATCH/PUT /incidents/1.json
  def update
    respond_to do |format|
      if @incident.update(incident_params)
        if @incident.update(:avatars => add_avatars)
          format.html { redirect_to :root, notice: 'インシデントを更新しました' }
          format.json { render :show, status: :ok, location: @incident }
        else
          format.html { render :edit }
          format.json { render json: @incident.errors, status: :unprocessable_entity }
        end
      else
        format.html { render :edit }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incidents/1
  # DELETE /incidents/1.json
  def destroy
    @incident.destroy
    respond_to do |format|
      format.html { redirect_to :root, notice: 'インシデントを削除しました' }
      format.json { head :no_content }
    end
  end

  def filter(ignores=[])
    #クエリストリングに含まれていた場合に、フィルタ条件から除外するキー
    ignores.push('page', 'row_limit', 'order', 'select', '_')

    @incidents = Incident.all.order('reception_date DESC, ID DESC').paginate(page: params[:page], per_page: 100)
    search_params = request.query_parameters
    search_params.delete("utf8")
    search_params.delete("commit")
    
    search_params = search_params.reject {|key, value| value.blank? }

    search_params.each do |key, value|
      next if ignores.include?(key)
      @incidents = @incidents.where("incidents.`#{key}` like ?", "%#{value}%")
    end
    
    @incidents
  end

  #既に添付ファイルがある場合に、既存の添付ファイルを消さないようにするための処理。
  def add_avatars
    new_avatars = params.dig(:incident, :avatars) ||
                 params.dig(:incident, :avatars).presence &&
                 JSON.parse(params.dig(:incident, :avatars))
    if new_avatars
      @myavatars = @incident.avatars
      @myavatars += new_avatars
      @myavatars
    end
  end

  #添付ファイルをDLするメソッド
  def download_picture()
    index = params[:index].to_i
    avatar_file = @incident.avatars
    filepath = avatar_file[index].current_path
    stat = File::stat(filepath)
    send_file(filepath, :filename => avatar_file[index].url.gsub(/.*\//,''), :length => stat.size)
  end

  #添付ファイルを削除するメソッド
  def delete_picture()
    #URLのおしりに添付ファイルのindexがついているので、取得
    index = request.path.sub!(/.*\./m, "").to_i
    remain_avatars = @incident.avatars
    #削除するとき、添付ファイルが最後のひとつであれば、avatars自体を削除。そうでなければ、指定されたavatarだけ削除。
    if index == 0 && @incident.avatars.size == 1
      @incident.remove_avatars!
    else
      deleted_avatars = remain_avatars.delete_at(index) 
      deleted_avatars.try(:remove!)
      @incident.avatars = remain_avatars
    end
    if @incident.save
      flash[:notice] = "添付ファイルを削除しました"
    else
      flash[:error] = "添付ファイルの削除に失敗しました" 
    end
    redirect_to edit_incident_path(@incident)
  end

  def analysis
    type_count
    term_count
    username_count
    costtime_count
    type_term_count
  end

  def type_count
    @type_count = @incidents.group(:type).count
    gon.type = @type_count.keys
    gon.type_count = [{data:@type_count.values}]
    render json: @type_count unless caller_locations(1).first.label == 'analysis'
    return [{data:@type_count.values}]
  end

  def term_count
    reception_date = Array.new
    reception_month = Array.new
    count = Array.new
    @month_count = Array.new

    @incidents.select(:reception_date).each {|t|reception_date.push(t.reception_date.strftime('%Y-%m-%d'))}
    reception_date.uniq!
    reception_date.each do |value|
      if value =~ /^([0-9]+-[0-9]+)/ 
        reception_month.push($1)
      end
    end
    reception_month.uniq!
    reception_month.each do |month|
      @month_count.push([month, Incident.where("reception_date like ?", "#{month}%").count])
      count.push(Incident.where("reception_date like ?", "#{month}%").count)
    end
    gon.month = reception_month
    gon.month_count = [{data:count}]
    #return true unless flag.nil?
    render json: count unless caller_locations(1).first.label == 'analysis'
    return count
  end

  def username_count
    incident_count_all = @incidents.count
    @user_count = @incidents.where.not(username: ["田中照之","中野雄一","浦野頌平","hinemos","Hinemos"])
                          .group(:username)
                          .order('count_username desc')
                          .limit(10)
                          .count(:username)
    other_count = incident_count_all - @user_count.values.sum
    @user_count.store("その他", other_count) unless other_count == 0
    gon.username = @user_count.keys
    gon.username_count = [{data: @user_count.values}]
    #return true unless flag.nil?
    render json: @user_count unless caller_locations(1).first.label == 'analysis'
    return @user_count
  end

  def type_term_count
    reception_date = Array.new
    reception_month = Array.new
    month_count = Array.new
    @type_count = Array.new
    @type_month_count = Hash.new
    @type_month_counts = Array.new

    @type_count = @incidents.group(:type).count

    @incidents.select(:reception_date).each {|t|reception_date.push(t.reception_date.strftime('%Y-%m-%d'))}
    reception_date.uniq!
    reception_date.each do |value|
      if value =~ /^([0-9]+-[0-9]+)/ 
        reception_month.push($1)
      end
    end
    reception_month.uniq!

    @type_count.keys.each do |type|
      month_count.clear
      @type_month_count.clear
      reception_month.each do |month|
        month_count.push(Incident.where(type: type).where("reception_date like ?", "#{month}%").count)
      end
      @type_month_count.store('label',type.to_str)
      @type_month_count.store('data',month_count)
      @type_month_count.store('fill','false')
      @type_month_counts << Marshal.load(Marshal.dump(@type_month_count))
    end
    gon.type_month_count = @type_month_counts
    gon.month = reception_month
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incident
      @incident = Incident.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def incident_params
      params.require(:incident).permit(:type, :reception_date, :group, :username, :hostname, :os, :product, :subject, :solution, :story, :status, :close_date, :remarks, :operator, :costtime)
    end

    def parse_date(argument_date)
      return_date = nil
      keys = argument_date.keys
      keys.each do |key|
        return_date += '/' + argument_date["#{key}"] unless return_date.nil?
        return_date = argument_date["#{key}"] if return_date.nil?
      end
      return_date.to_date.strftime('%Y-%m-%d')
    end

    #viewのselect_tagで表示させる選択肢を生成する
    def make_choice
      @choice_type=[]
      Choice.where("column_name = ?", "type").order("value").each {|t|@choice_type.push(t.value)}

      @choice_status=[]
      Incident.select("status").distinct.each {|t|@choice_status.push(t.status)}
      @choice_status.sort
      
      @choice_operator=[]
      Choice.where("column_name = ?", "operator").order("value").each {|t|@choice_operator.push(t.value)}
    end

    def all_incident_count
      @all_incidents_count = Incident.all.count
    end

    def filter_by_date
      qp = request.query_parameters
      @incidents = Incident.all
      @incidents = @incidents.where("reception_date >= ? and reception_date <= ?", qp['start'], qp['end']) unless qp.blank?
    end

    # def incident_type_count
    #   incidents_type = Array.new
    #   @incident_type_count = Array.new
    #   Choice.where("column_name = ?", "type").each {|t|incidents_type.push(t.value)}
    #   incidents_type.each do |incident_type|
    #     @incident_type_count.push([incident_type, Incident.where("type = ?", "#{incident_type}").count]) 
    #   end
    #   @incident_type_count
    # end

    def user_count
      @user_count = Incident.where.not(username: ["中野雄一","浦野頌平","hinemos","Hinemos"])
                            .group(:username)
                            .order('count_username desc')
                            .limit(10)
                            .count(:username)
      p @user_count
      other_count = @all_incidents_count - @user_count.values.sum
      @user_count.store("その他", other_count)
    end

    def costtime_count
      reception_date = Array.new
      reception_month = Array.new
      @costtime_count = Array.new
      count = Array.new
      Incident.select(:reception_date).each {|t|reception_date.push(t.reception_date.strftime('%Y-%m-%d'))}
      reception_date.uniq!
      reception_date.each do |value|
        if value =~ /^([0-9]+-[0-9]+)/ 
          reception_month.push($1)
        end
      end
      reception_month.uniq!
      reception_month.each do |month|
        @costtime_count.push([month, (Incident.where("reception_date like ?", "#{month}%").sum(:costtime).to_f/60).round(2)])
        count.push((Incident.where("reception_date like ?", "#{month}%").sum(:costtime).to_f/60).round(2))
      end
      gon.costtime = reception_month
      gon.costtime_count = [{data:count}]
      return [{data:@count}]
    end
end
