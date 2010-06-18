class RatingController < ApplicationController

  def rate
    @posts = Post.find(params[:id])
    Rating.delete_all(["rateable_type = 'Post' AND rateable_id = ? AND user_id = ?", @posts.id, @user_id])
    @posts.add_rating Rating.new(:rating => params[:rating])
  end

end