class QuestionsController < InheritedResources::Base
  actions :all, :except => [ :show, :edit, :delete ]
  before_action :require_login
  respond_to :xml, :json
  respond_to :csv, :only => :export #leave the option for xml export here
  belongs_to :site, :optional => true

  def show
    @question = current_user.questions.find(params[:id])

    begin
        @question_optional_information = @question.get_optional_information(params)
    rescue RuntimeError => e
      logger.error(e)
      respond_to do |format|
        format.json { render :xml => @question.to_json, :status => :conflict and return}
        format.xml { render :xml => @question.to_xml, :status => :conflict and return}
      end
    end

    optional_information = []
    @question_optional_information.each do |key, value|
      optional_information << Proc.new { |options| options[:builder].tag!(key, value)}
    end
    response_options = { :methods => [:item_count], :procs => optional_information }
    response_options[:include] = :versions if params[:version] == "all"
+
    logger.info("DEBUG DEBUG DEBUG")
    logger.info("response options are #{response_options.inspect}")
    logger.info(@question.to_json(response_options))
    logger.info(@question_optional_information)

    respond_to do |format|
      format.xml {
        render :xml => @question.to_xml(response_options)
      }
      format.json {
        render :json => @question.attributes.merge(@question_optional_information).to_json(response_options)
      }
    end
  end

  def create
    logger.info "all params are #{params.inspect}"
    logger.info "vi is #{params['visitor_identifier']} and local are #{params['local_identifier']}."
    if @question =
        current_user.create_question(
          params['visitor_identifier'],
          :name => params['name'],
          :local_identifier => params['local_identifier'],
          :information => params['information'],
          :ideas => (params['ideas'].lines.to_a.delete_if {|i| i.blank?} rescue nil)
         )
      respond_to do |format|
        format.xml { render :xml => @question.to_xml}
        format.json { render :xml => @question.to_json}
      end
    else
      respond_to do |format|
        format.xml { render :xml => @question.errors.to_xml}
        format.json { render :xml => @question.errors.to_json}
      end
    end
  end

  def export
    type = params[:type]
    key  = params[:key]

    if key.nil?
      render :text => "Error! Specify a key for the export" and return
    end
    if type.nil?
      render :text => "Error! Specify a type of export" and return
    end

    @question = current_user.questions.find(params[:id])
    @question.delay(:priority => 15).export(type, :key => key)

    render :text => "Ok! Please wait for the response"
  end

  def median_votes_per_session
    @question = current_user.questions.find(params[:id])
    respond_to do |format|
      format.xml{ render :xml => {:median => @question.median_votes_per_session}.to_xml and return}
    end
  end

  def median_responses_per_session
    @question = current_user.questions.find(params[:id])
    respond_to do |format|
      format.xml{ render :xml => {:median => @question.median_responses_per_session}.to_xml and return}
    end
  end

  def votes_per_uploaded_choice
    @question = current_user.questions.find(params[:id])
    only_active = params[:only_active] == 'true'
    respond_to do |format|
      format.xml{ render :xml => {:value => @question.votes_per_uploaded_choice(only_active)}.to_xml and return}
    end
  end

  def object_info_by_visitor_id

    object_type = params[:object_type]
    @question = current_user.questions.find(params[:id])

    visitors = []
    if object_type == "votes"
      votes_by_visitor_id= Vote.select('visitors.identifier as thevi, count(*) as the_votes_count').joins(:voter).where(:question_id => @question.id).group("voter_id")


      votes_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.the_votes_count})
      end
    elsif object_type == "skips"
      skips_by_visitor_id= Skip.select('visitors.identifier as thevi, count(*) as the_votes_count').joins(:skipper).where(:question_id => @question.id).group("skipper_id")


      skips_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.the_votes_count})
      end
    elsif object_type == "uploaded_ideas"

      uploaded_ideas_by_visitor_id = @question.choices.select('creator_id, count(*) as ideas_count').where("choices.creator_id != #{@question.creator_id}").group('creator_id')

      count = 0
      uploaded_ideas_by_visitor_id.each do |visitor|
        v = Visitor.find(visitor.creator_id, :select => 'identifier')

        logger.info(v.identifier)

        if v.identifier.include?(" ") || v.identifier.include?("'")
          v.identifier = "no_data#{count}"
          count +=1
        end
        logger.info(v.identifier)

        visitors.push({:visitor_id => v.identifier, :count => visitor.ideas_count})
      end

    elsif object_type == "bounces"

      possible_bounces = @question.appearances.count(:group => :voter_id, :having => 'count_all = 1')
            possible_bounce_ids = possible_bounces.inject([]){|list, (k,v)| list << k}

      voted_at_least_once = @question.votes.select(:voter_id).where(:voter_id => possible_bounce_ids)
      voted_at_least_once_ids = voted_at_least_once.inject([]){|list, v| list << v.voter_id}

      bounces = possible_bounce_ids - voted_at_least_once_ids

      bounces.each do |visitor_id|
        v = Visitor.find(visitor_id, :select => 'identifier')

        if v.identifier
           visitors.push({:visitor_id => v.identifier, :count => 1})
        end
      end
    end
    respond_to do |format|
      format.xml{ render :xml => visitors.to_xml and return}
    end
  end

  def all_num_votes_by_visitor_id
    scope = params[:scope]

    visitors = []
    if scope == "all_votes"

      votes_by_visitor_id= Vote.select('visitors.identifier as thevi, count(*) as the_votes_count').joins(:voter).group("voter_id")
      votes_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.the_votes_count})
      end
    elsif scope == "all_photocracy_votes"

      votes_by_visitor_id= Vote.select('visitors.identifier as thevi, count(*) as the_votes_count').joins(:voter).where(:visitors => { :site_id => PHOTOCRACY_SITE_ID }).group("voter_id")
      votes_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.the_votes_count})
      end
    elsif scope == "all_aoi_votes"

      votes_by_visitor_id= Vote.select('visitors.identifier as thevi, count(*) as the_votes_count').joins(:voter).where(:visitors => { :site_id => ALLOURIDEAS_SITE_ID }).group("voter_id")
      votes_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.the_votes_count})
      end
    elsif scope == "creators"

      questions_created_by_visitor_id = Question.select('visitors.identifier as thevi, count(*) as questions_count').joins(:creator).group('creator_id')
      questions_created_by_visitor_id.each do |visitor|
        visitors.push({:visitor_id => visitor.thevi, :count => visitor.questions_count})
      end

    end
    respond_to do |format|
      format.xml{ render :xml => visitors.to_xml and return}
    end
  end

  def vote_rate
    @question = current_user.questions.find(params[:id])
    response = {:voterate => @question.vote_rate}
    respond_to do |format|
      format.xml { render :xml => response.to_xml and return}
    end
  end

  def upload_to_participation_rate
    @question = current_user.questions.find(params[:id])
    response = {:uploadparticipationrate => @question.upload_to_participation_rate}
    respond_to do |format|
      format.xml { render :xml => response.to_xml and return}
    end
  end

  def object_info_totals_by_date
    object_type = params[:object_type]

    @question = current_user.questions.find(params[:id])

    if object_type == 'votes'
      data = Vote.count(:conditions => "question_id = #{@question.id}", :group => "date(created_at)")
    elsif object_type == 'skips'
      data = Skip.count(:conditions => {:question_id => @question.id}, :group => "date(created_at)")
    elsif object_type == 'user_submitted_ideas'
      data = Choice.count(:conditions => "choices.question_id = #{@question.id} AND choices.creator_id <> #{@question.creator_id}",
        :group => "date(choices.created_at)")
      # we want graphs to go from date of first vote -> date of last vote, so adding those two boundries here.
      mindate = Vote.minimum('date(created_at)', :conditions => {:question_id => @question.id}).try(:to_date)
      maxdate = Vote.maximum('date(created_at)', :conditions => {:question_id => @question.id}).try(:to_date)

      data[mindate] = 0 if !data.include?(mindate) && !mindate.nil?
      data[maxdate] = 0 if !data.include?(maxdate) && !maxdate.nil?
    elsif object_type == 'user_sessions'
      # little more work to do here:
      result = Vote.select('date(created_at) as date, voter_id, count(*) as vote_count').where("question_id = #{@question.id}").group('date(created_at), voter_id')
      data = Hash.new(0)
      result.each do |r|
        data[r.date]+=1
      end

    elsif object_type == 'appearances_by_creation_date'

            array = []
      @question.choices.active.order(:created_at).each do |c|
               relevant_prompts = c.prompts_on_the_left.select('id') + c.prompts_on_the_right.select('id')

         appearances = Appearance.count(:conditions => {:prompt_id => relevant_prompts, :question_id => @question.id})

         #initialize key to list if it doesn't exist
         array << {:date => c.created_at.to_date, :data => c.data, :appearances => appearances}
      end


    end

    # all but appearances_by_creation_date create data hash that needs
    # to be converted to array
    if data && !array
      array = []
      data.each do |key, value|
        array << {:date => key, :count => value}
      end
    end

    respond_to do |format|
      format.xml { render :xml => array.to_xml and return}
    end
  end

  def all_object_info_totals_by_date
    object_type = params[:object_type]

    hash = {}
    if object_type == 'votes'
      hash = Vote.count(:group => "date(created_at)")
    elsif object_type == 'user_submitted_ideas'
      hash = Choice.count(:include => :question,
              :conditions => "choices.creator_id <> questions.creator_id",
        :group => "date(choices.created_at)")
    elsif object_type == 'user_sessions'
      result = Vote.select('date(created_at) as date, voter_id, count(*) as vote_count').group('date(created_at), voter_id')
      hash = Hash.new(0)
      result.each do |r|
        hash[r.date]+=1
      end
    end

    array = []
    hash.each do |key, value|
      array << {:date => key, :count => value}
    end
    respond_to do |format|
      format.xml { render :xml => array.to_xml and return}
    end
  end

  def update
    # prevent AttributeNotFound error and only update actual Question columns, since we add extra information in 'show' method
    question_attributes = Question.new.attribute_names
    params[:question] = params[:question].delete_if {|key, value| !question_attributes.include?(key)}
    @question = current_user.questions.find(params[:id])
    update!
  end

  def site_stats
    results = Question.connection.select_one("SELECT COUNT(*) as total_questions, SUM(votes_count) as votes_count, SUM(choices_count) choices_count FROM questions where site_id = #{current_user.id}")
    results.each do |key, value|
      results[key] = value.to_i
    end
    respond_to do |format|
      format.xml {
        render :xml => results.to_xml
      }
      format.json{
        render :json => results.to_json
      }
    end
  end

  def index

    counts = {}
    if params[:user_ideas]
      counts['user-ideas'] = Choice.count(:joins => :question,
                                         :conditions => "choices.creator_id <> questions.creator_id",
                                         :group => "choices.question_id")
    end
    if params[:active_user_ideas]
      counts['active-user-ideas'] = Choice.count(:joins => :question,
                                                :conditions => "choices.active = 1 AND choices.creator_id <> questions.creator_id",
                                                :group => "choices.question_id")
    end
    if params[:votes_since]
      counts['recent-votes'] = Vote.count(:joins => :question,
                                         :conditions => ["votes.created_at > ?", params[:votes_since]],
                                         :group => "votes.question_id")
    end

    # only return questions with these recent votes
    if counts['recent-votes'] && params[:all] != 'true'
      @questions = current_user.questions.scoped({}).where(id: counts['recent-votes'].keys)
    else
      @questions = current_user.questions.scoped({})
      @questions = @questions.created_by(params[:creator]) if params[:creator]
    end

    # There doesn't seem to be a good way to add procs to an array of
    # objects. This  solution  depends on Array#to_xml rendering each
    # member in the correct order. Internally, it just uses, #each, so
    # this _should_ work.
    ids = Enumerator.new{ |g|  @questions.each{ |q| g.yield q.id } }
    extra_info = Proc.new do |o|
      id = ids.next
      counts.each_pair do |attr, hash|
        o[:builder].tag!(attr, hash[id] || 0 , :type => "integer")
      end
    end

    index! do |format|
      format.xml do
        render :xml => @questions.to_xml(:procs => [ extra_info ])
      end
    end
  end

  protected
end

class String
  unless defined? "".lines
    alias lines to_a
    #Ruby version compatibility
  end
end
