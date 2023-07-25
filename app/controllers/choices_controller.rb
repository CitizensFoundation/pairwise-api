class ChoicesController < InheritedResources::Base
  respond_to :xml, :json
  actions :show, :index, :create, :update, :new
  belongs_to :question
  has_scope :active, :type => :boolean, :only => :index

  before_action :require_login

  def show_votes
    choice = Choice.find(params[:id])
    votes = get_all_votes(choice, params)
    render json: { winning_votes: votes[:winning_votes], losing_votes: votes[:losing_votes] }
  end

  def index
    params[:limit] = 1000 unless params[:limit]
    @question = current_user.questions.find(params[:question_id])
    find_options = {:conditions => {:question_id => @question.id}}
    find_options[:conditions].merge!(:active => true) unless params[:include_inactive]
    find_options.merge!(:offset => params[:offset]) if params[:offset]
    where_options = find_options[:conditions].map{ |el| "choices.#{el.first}=#{el.last}" }.join(" AND ")
    @choices = Choice.where(where_options).limit(params[:limit].to_i).order('score DESC').offset(params[:offset].to_i)
    puts "where_options: #{where_options}"

    @choices.each do |choice|
      votes = get_all_votes(choice, params)
      choice.wins = votes[:winning_votes].count
      choice.losses = votes[:losing_votes].count
      choice.score = (choice.wins.to_f + 1) / (choice.wins + 1 + choice.losses + 1) * 100
    end

    out_choices = []
    @choices.each do |choice|
      if choice.wins+choice.losses > 9
        out_choices << choice
      end
    end
    @choices = out_choices.sort_by(&:score).reverse

    index! do |format|
      format.json { render :xml => @choices.to_json(:only => [ :data, :score, :id, :active, :created_at, :wins, :losses, :elo_rating], :methods => :user_created)}
      format.xml { render :xml => @choices.to_xml(:only => [ :data, :score, :id, :active, :created_at, :wins, :losses, :elo_rating], :methods => :user_created)}
    end
  end

  def get_all_votes(choice, params)
    winning_votes = Vote.where(choice_id: choice.id)
    losing_votes = Vote.where(loser_choice_id: choice.id)

    if params[:utm_source]
      winning_votes = winning_votes.where("votes.tracking LIKE ?", "%utm_source: #{params[:utm_source]}%")
      losing_votes = losing_votes.where("votes.tracking LIKE ?", "%utm_source: #{params[:utm_source]}%")
    end
    if params[:utm_campaign]
      winning_votes = winning_votes.where("votes.tracking LIKE ?", "%utm_campaign: #{params[:utm_campaign]}%")
      losing_votes = losing_votes.where("votes.tracking LIKE ?", "%utm_campaign: #{params[:utm_campaign]}%")
    end

    { winning_votes: winning_votes, losing_votes: losing_votes }
  end

  def index_old
    if params[:limit]
      @question = current_user.questions.find(params[:question_id])

      find_options = {:conditions => {:question_id => @question.id}
		      }

      find_options[:conditions].merge!(:active => true) unless params[:include_inactive]
      find_options.merge!(:offset => params[:offset]) if params[:offset]

      where_options = find_options[:conditions].map{ |el| "#{el.first}=#{el.last}" }.join(" AND ")

      @choices = Choice.where(where_options).limit(params[:limit].to_i).order('score DESC').offset(params[:offset].to_i)
    else
      @question = current_user.questions.where(id: params[:question_id]).includes(:choices).first #eagerloads ALL choices
      unless params[:include_inactive]
        @choices = @question.choices.active.all
      else
        @choices = @question.choices.all
      end
    end
    index! do |format|
      format.json { render :xml => @choices.to_json(:only => [ :data, :score, :id, :active, :created_at, :wins, :losses], :methods => :user_created)}
      format.xml { render :xml => @choices.to_xml(:only => [ :data, :score, :id, :active, :created_at, :wins, :losses], :methods => :user_created)}
    end

  end

  def votes
    @choice = Choice.find(params[:id])
    render :xml => @choice.votes.to_xml
  end

  # Similar finds similar choices as the choice given for the question.
  # Currently, it only returns choices that are identical.
  def similar
    @question = current_user.questions.find(params[:question_id])
    choice = @question.choices.find(params[:id])
    @similar = @question.choices.active.where("data = ? and id <> ?", choice.data, choice.id)
    render :xml => @similar.to_xml
  end

  def create

    params[:choice][:visitor_identifier] = params[:visitor_identifier]

    visitor_identifier = params[:choice].delete(:visitor_identifier)
    puts "visitor_identifier: #{visitor_identifier}"

    visitor = current_user.default_visitor
    puts "visitor 1: #{visitor}"
    puts "current_user: #{current_user}"
    if visitor_identifier
      visitor = current_user.visitors.find_or_create_by(identifier: visitor_identifier)
    end

    params[:choice].merge!(:creator => visitor)

    puts "visitor 2: #{visitor}"
    puts "params[:choice]: #{params[:choice]}"

    @question = current_user.questions.find(params[:question_id])
    params[:choice].merge!(:question_id => @question.id)

    if ENV.has_key?("OPENAI_API_KEY")
      params[:choice][:active] = true
    end

    @choice = Choice.new(params[:choice])
    create!
  end

  def flag
    @question = current_user.questions.find(params[:question_id])
    @choice = @question.choices.find(params[:id])

    flag_params = {:choice_id => params[:id].to_i, :question_id => params[:question_id].to_i, :site_id => current_user.id}

    if explanation = params[:explanation]
	    flag_params.merge!({:explanation => explanation})

    end
    if visitor_identifier = params[:visitor_identifier]
            visitor = current_user.visitors.find_or_create_by(identifier: visitor_identifier)
	    flag_params.merge!({:visitor_id => visitor.id})
    end
    respond_to do |format|
	    if @choice.deactivate!
                    flag = Flag.create!(flag_params)
		    format.xml { render :xml => @choice.to_xml, :status => :created }
		    format.json { render :json => @choice.to_json, :status => :created }
	    else
		    format.xml { render :xml => @choice.errors, :status => :unprocessable_entity }
		    format.json { render :json => @choice.to_json }
	    end
    end

  end

  def update
    # prevent AttributeNotFound error and only update actual Choice columns, since we add extra information in 'show' method
    choice_attributes = Choice.new.attribute_names
    params[:choice] = params[:choice].delete_if {|key, value| !choice_attributes.include?(key)}
    Choice.transaction do
      # lock question since we'll need a lock on it later in Choice.update_questions_counter
      @question = current_user.questions.lock(true).find(params[:question_id])
      @choice = @question.choices.find(params[:id])
      update!
    end
  end

  def show
    @question = current_user.questions.find(params[:question_id])
    @choice = @question.choices.find(params[:id])
    response_options = {}
    response_options[:include] = :versions if params[:version] == 'all'

    respond_to do |format|
      format.xml { render :xml => @choice.to_xml(response_options) }
      format.json { render :json => @choice.to_json(response_options) }
    end
  end


  def calculate_elo(rating1, rating2, score1, score2)
    k_factor = 32
    expected1 = 1.0 / (1 + 10 ** ((rating2 - rating1) / 400.0))
    expected2 = 1.0 / (1 + 10 ** ((rating1 - rating2) / 400.0))
    new_rating1 = rating1 + k_factor * (score1 - expected1)
    new_rating2 = rating2 + k_factor * (score2 - expected2)
    return new_rating1, new_rating2
  end

end

