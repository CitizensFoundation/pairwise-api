class DensitiesController < InheritedResources::Base
  respond_to :xml, :json
  before_filter :authenticate
  actions :index

  def index
      if params[:question_id]
	      logger.info(" Got a question id")
	      @densities = Density.where(:question_id => params[:question_id]).order(:created_at)
      end
      index!
  end


end
