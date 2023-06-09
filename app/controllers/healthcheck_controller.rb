class HealthcheckController < InheritedResources::Base
  def index
    respond_to do |format|
      format.json { render json: { status: :ok } }
      format.any { render body: nil, status: :ok }
    end
  end
end
