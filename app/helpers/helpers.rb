ActivateApp::App.helpers do
  
  def current_account
    @current_account ||= Account.find(session[:account_id]) if session[:account_id]
  end
   
  def sign_in_required!
    unless current_account
      flash[:notice] = 'You must sign in to access that page'
      session[:return_to] = request.url
      request.xhr? ? halt : redirect(url(:accounts, :sign_in))
    end
  end  
  
  def f(slug)
    (if fragment = Fragment.find_by(slug: slug) and fragment.body
        "\"#{fragment.body.to_s.gsub('"','\"')}\""
      end).to_s
  end  
  
  def gatheringship_required!(gathering=nil)
    gathering = @gathering if !gathering
    unless current_account and gathering and (gathering.gatheringships.find_by(account: current_account) or current_account.admin?)
      flash[:notice] = 'You must be a member of that gathering to access that page'
      session[:return_to] = request.url
      request.xhr? ? halt(403) : redirect(current_account ? '/' : '/sign_in')
    end        
  end  
  
end