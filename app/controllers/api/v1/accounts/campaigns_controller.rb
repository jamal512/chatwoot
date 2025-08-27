class Api::V1::Accounts::CampaignsController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :set_campaign, only: [:show, :update, :destroy, :execute]

  def index
    @campaigns = Current.account.campaigns.page(params[:page])
  end

  def show; end

  def create
    @campaign = Current.account.campaigns.build(campaign_params)
    @campaign.user = current_user
    @campaign.status = :draft

    if @campaign.save
      render json: @campaign, status: :created
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      render json: @campaign
    else
      render json: { errors: @campaign.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @campaign.destroy
    head :no_content
  end

  def execute
    execution_result = N8nService.new.trigger_workflow(@campaign)
    ExecuteCampaignJob.perform_later(@campaign)
    
    render json: { 
      message: 'started', 
      execution_id: execution_result[:execution_id] 
    }
  end

  private

  def set_campaign
    @campaign = Current.account.campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description, :campaign_type, :status, 
                                   :scheduled_at, target_segments: {}, message_templates: {})
  end

  def check_authorization
    authorize(Campaign) if action_name.in?(%w[create update destroy execute])
  end
end
