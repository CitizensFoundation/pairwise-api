PairwiseApi::Application.routes.draw do
  resources :densities, :only => :index
  resources :visitors, :only => :index do
    collection do
      post :objects_by_session_ids
    end
    member do
      get :votes
    end
  end

  resources :exports, :only => :show
  resources :questions, :except => [:edit, :destroy] do
    collection do
      get :all_num_votes_by_visitor_id
      get :all_object_info_totals_by_date
      get :site_stats
      get :object_info_totals_by_question_id
      get :recent_votes_by_question_id
    end
    member do
      get :object_info_totals_by_date
      get :object_info_by_visitor_id
      get :median_votes_per_session
      get :vote_rate
      get :median_responses_per_session
      get :votes_per_uploaded_choice
      get :upload_to_participation_rate
      post :export
    end
    resources :prompts, :only => :show do
      member do
        post :skip
        post :vote
      end
    end

    resources :choices, :only => [:show, :index, :create, :update, :new] do
      member do
        put :flag
        get :votes
        get :similar
      end
    end
  end

end
