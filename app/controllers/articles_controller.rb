class ArticlesController < ApplicationController
  require 'will_paginate/array'
  before_action :set_post, only: %i[ show edit upvote downvote like unlike]
  before_action :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource


  def index
    @articles = Article.accessible_by(current_ability)
    @articles = Article.all.order(cached_votes_score: :desc)
  end


  def show
    authorize! :read, @article
  end
  
  def new
    @article = current_user.articles.build
  end

  def create 
    @article = current_user.articles.build(article_params)
    @article.user_id = current_user.id
    if @article.save
      flash[:notice] = "Article was created"
      redirect_to article_url(@article)      
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @article = Article.find(params[:id])
    if @article.update(article_params)
      flash[:notice] = "Article was updated"
      redirect_to @article
    else
      flash[:notice] = "Article was not updated"
      render :edit, status: :unprocessable_entity
    end

  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    params[:id] = nil
    flash[:notice] = "Article has been deleted"
    redirect_to :action => :index
  end

  def upvote
    if current_user.voted_up_on? @article
      @article.unliked_by current_user
    else
      @article.upvote_from current_user
    end
      respond_to do |format|  
        format.html {redirect_to root_path}     
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(root_path, partial: "articles/article",
            locals: { article: @article })
        end
        
      end
  end

  def downvote
    if current_user.voted_down_on? @article
      @article.unliked_by current_user
    else
      @article.downvote_from current_user
    end
    respond_to do |format| 
      format.html {redirect_to root_path}    
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(root_path, partial: "articles/article",
          locals: { article: @article })
      end
      
    end
  end

  private

  def set_post
    @article=Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :image)
  end
end
