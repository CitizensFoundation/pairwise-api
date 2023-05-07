# Rails 7 code that should work
class PromptsController < InheritedResources::Base
  respond_to :xml, :json
  actions :show
  belongs_to :question

  has_scope :voted_on_by
  before_action :require_login

  def vote
    @question = current_user.questions.find(params[:question_id])
    @prompt = @question.prompts.find(params[:id])

    vote_options = params[:vote] || {}
    vote_options.merge!(:prompt => @prompt, :question => @question)

    successful = object = current_user.record_vote(vote_options)

    optional_information = []
    if params[:next_prompt]
       begin
           params[:next_prompt].merge!(:with_prompt => true)
           @question_optional_information = @question.get_optional_information(params[:next_prompt])
       rescue RuntimeError
           respond_to do |format|
              format.xml { render :xml => @prompt.to_xml, :status => :conflict and return}
              format.json { render :json => @prompt.to_json, :status => :conflict and return }
           end
       end
       object = @question.prompts.find(@question_optional_information.delete(:picked_prompt_id))
       @question_optional_information.each do |key, value|
          optional_information << Proc.new { |options| options[key] = value }
       end
    end

    object_hash = JSON.parse(object.to_json)
    optional_information.each { |proc| proc.call(object_hash) }
    object_hash[:left_choice_text] = object.left_choice.data
    object_hash[:right_choice_text] = object.right_choice.data

    final_json = JSON.dump(object_hash)

    respond_to do |format|
      if !successful.nil?
        format.json { render :json => final_json, :status => :ok }
      else
        format.json { render :json => @prompt.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def skip
    logger.info "#{current_user.inspect} is skipping."
    @question = current_user.questions.find(params[:question_id])
    @prompt = @question.prompts.find(params[:id])

    skip_options = params[:skip] || {}
    skip_options.merge!(:prompt => @prompt, :question => @question)

    successful = response = current_user.record_skip(skip_options)
    if successful.nil?
      puts "DEBUG Failed to skip prompt #{params[:id]} with options #{skip_options.inspect} for user #{current_user.inspect}"
    end
    optional_information = []
    if params[:next_prompt]
       begin
           params[:next_prompt].merge!(:with_prompt => true) # We always want to get the next possible prompt
           @question_optional_information = @question.get_optional_information(params[:next_prompt])
       rescue RuntimeError

           respond_to do |format|
              format.xml { render :xml => @prompt.to_xml, :status => :conflict and return}
              format.json { render :json => @prompt.to_json, :status => :conflict and return }
           end
       end

       response = @question.prompts.find(@question_optional_information.delete(:picked_prompt_id))
       @question_optional_information.each do |key, value|
          optional_information << Proc.new { |options| options[:builder].tag!(key, value)}
       end
    end
    respond_to do |format|
      if !successful.nil?
        format.xml { render :xml => response.to_xml(:procs => optional_information , :methods => [:left_choice_text, :right_choice_text]), :status => :ok }
        format.json { render :json => response.to_json(:procs => optional_information, :methods => [:left_choice_text, :right_choice_text]), :status => :ok }
      else
        format.xml { render :xml => @prompt.to_xml, :status => :unprocessable_entity }
        format.json { render :json => @prompt.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @question = current_user.questions.find(params[:question_id])
    @prompt = @question.prompts.where(id: params[:id]).includes([:left_choice ,:right_choice]).first
    show! do |format|
      format.xml { render :xml => @prompt.to_xml(:methods => [:left_choice_text, :right_choice_text])}
      format.json { render :json => @prompt.to_json(:methods => [:left_choice_text, :right_choice_text])}
    end
  end


  protected
    def begin_of_association_chain
      current_user.questions.find(params[:question_id])
    end

    def collection
      if params[:choice_id].blank?
        @prompts
      else
        end_of_association_chain.with_choice_id(params[:choice_id])
      end
    end
end
