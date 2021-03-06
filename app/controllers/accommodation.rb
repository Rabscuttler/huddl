Huddl::App.controller do
    
  post '/h/:slug/accoms/new' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!    
    @accom = @group.accoms.build(params[:accom])
    @accom.account = current_account
    if @accom.save
      redirect "/h/#{@group.slug}/accoms"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the accommodation from being saved."
      erb :'accoms/build'    
    end
  end  
  
  get '/h/:slug/accoms' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    membership_required!
    if request.xhr?
      partial :'accoms/accoms'
    else
      erb :'accoms/accoms'
    end
  end
    
  get '/h/:slug/accoms/:id/edit' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!    
    @accom = @group.accoms.find(params[:id])
    erb :'accoms/build'
  end
  
  post '/h/:slug/accoms/:id/edit' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!    
    @accom = @group.accoms.find(params[:id])
    if @accom.update_attributes(params[:accom])
      redirect "/h/#{@group.slug}/accoms"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the accommodation from being saved." 
      erb :'accoms/build'
    end
  end  
  
  get '/h/:slug/accoms/:id/destroy' do
    @group = Group.find_by(slug: params[:slug]) || not_found
    @membership = @group.memberships.find_by(account: current_account)
    group_admins_only!    
    @accom = @group.accoms.find(params[:id])
    @accom.destroy
    redirect "/h/#{@group.slug}/accoms"      
  end 
    
  get '/accomships/create' do
    @accom = Accom.find(params[:accom_id]) || not_found
    @group = @accom.group      
    membership_required!      
    Accomship.create(account: current_account, accom_id: params[:accom_id], group: @group)
    200
  end    
    
  get '/accomships/:id/destroy' do
    @accomship = Accomship.find(params[:id]) || not_found
    @group = @accomship.accom.group
    @membership = @group.memberships.find_by(account: current_account)
    halt unless @accomship.account.id == current_account.id or @membership.admin?
    @accomship.destroy
    200
  end        
  
end