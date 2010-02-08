class CommentController < ApplicationController

  
  skip_before_filter :authorize, :except => [:destroy, :purge_comments]
  verify :method => :post, :only => [:create, :update],
         :redirect_to => :back
  verify :method => :delete, :only => [:destroy, :purge_comments],
         :redirect_to => :back

 

  def create 
    @mod = find_mod(params[:resource_id],"CommentResource")
    params[:comment][:author_name] = params[:comment][:author_name].empty? ? "Anonymous" : params[:comment][:author_name]

    #if verify_recaptcha(:model => @mod)
    if verify_recaptcha
      comment = Comment.new(params[:comment].merge(:comment_resource_id => @mod.id))
      unless comment.save
        flash[:author_email_error] = comment.errors[:author_email]
        flash[:body_error] = comment.errors[:body]
        flash[:author_email] = comment.author_email
        flash[:author_name] = comment.author_name
        flash[:body] = comment.body
      end
    else
      flash[:author_email] = params[:comment][:author_email]
      flash[:author_name] = params[:comment][:author_name]
      flash[:body] = params[:comment][:body]
    end
    redirect_to :back
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to :back
  end

  def purge_comments
    @mod = find_mod(params[:resource_id],"CommentResource")
    @mod.comments.delete_all
    redirect_to :back
  end
end
