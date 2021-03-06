Huddl::App.controller do

  get '/h/:slug/budget' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    if request.xhr?
      partial :'budget/budget'
    else
      erb :'budget/budget'
    end
  end

  post '/spends/create' do
    @group = Group.find(params[:group_id]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    Spend.create(item: params[:item], amount: params[:amount], account: current_account, group: @group)
    200
  end
    
  get '/spends/:id/destroy' do
    @spend = Spend.find(params[:id]) || not_found
    @group = @spend.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    @spend.destroy
    200
  end     
    
  post '/spends/:id/reimbursed' do
    @spend = Spend.find(params[:id]) || not_found
    @group = @spend.group
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!
    @spend.update_attribute(:reimbursed, params[:reimbursed])
    200  
  end      
    
end