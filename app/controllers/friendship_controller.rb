class FriendshipController < ApplicationController
  
  def acceptfriend 
     @friend=Friendship.find_by_user_id_and_friend_id(params[:id],session[:user_id] )
   
      @friend.friend_stage='friend'
       if @friend.save
        flash[:notice] = 'Friend was added.'
         redirect_to :action => 'collector', :controller=>'posts', :id => session[:user_id]
    end    
    end
 
  def addfriend 
      if params[:id] 
        connector = Friendship.new 
        connector.user_id = session[:user_id].id 
        connector.friend_id = params[:id] 
        connector.save 
        redirect_to :action => 'collection', :controller=>'posts', :id => @post_id
      end
  end
  
 
   
   def invitefriend 
     if session[:user_id]
     @collector=params[:collector]
     if params[:id] 
if @friend=Friendship.find_by_user_id_and_friend_id(session[:user_id], params[:id] )
          flash[:notice] = '&nbsp You have already requested friendship. Status is: ' + @friend.friend_stage

elsif  @friend=Friendship.find_by_user_id_and_friend_id(params[:id], session[:user_id])
    if @friend.update_attributes(:friend_stage=>'friend')
      flash[:notice] = 'Friendship established. This user had previuosly requested friendship. Status is: ' + @friend.friend_stage
       @collector=params[:id]
    end
                
 else 
      connector = Friendship.new 
        connector.user_id = session[:user_id]
        connector.friend_id = params[:id] 
        connector.friend_stage="invite"
        connector.save
         flash[:notice] = 'A friendship request has been sent.' 
        
    end 
     redirect_to :action => 'collector', :controller=>'posts', :id => params[:collector]
     end   
   else
      flash[:notice] ="You need to be logged in"
      redirect_to :action => 'login', :controller=>'login', :id => params[:id]
    end
    end
  
    def rejectfriend 
     end
     
     def terminatefriend 
      end
  
end