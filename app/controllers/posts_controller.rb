class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :like]

  before_action :authenticate_user!

  load_and_authorize_resource

  # GET /posts
  # GET /posts.json
  def index
    # follower 수를 기준으로 한 추천 사용자
    @suggested_friends_by_followers =  User.all.sort{|a,b| b.followers.count <=> a.followers.count}.first(10)
    # 최근 책짹
    @recent_posts = Post.order(id: :desc).limit(10);
    # 가장 많은 좋아요를 받은 책짹
    @favorite_posts = Post.all.sort{|a,b| b.like_users.count <=> a.like_users.count}.first(10)

    @posts = Post.where(user_id: current_user.followees.ids.push(current_user.id)).order(created_at: :desc)

  end

  # GET /posts/1
  # GET /posts/1.json
  def show
#    아직 이럴 필요까진 없는 듯...
#    @comments = if params[:comment]
#                  @post.comments.where(id: params[:comment])
#                else
#                  @post.comments.where(parent_id: nil)
#                end
#    @comments = @comments.page(params[:page].per(5)
  end

  # # GET /posts/new
  # def new
  #   @post = Post.new
  # end

  # GET /posts/1/edit
  def edit
    @posts = Post.where(postable_id: @post.postable.id).order(created_at: :desc)
    redirect_to root_path and return unless @post.user == current_user
  end

  # # POST /posts
  # # POST /posts.json
  # def create
  #   # @post = Post.new(post_params)
  #   @post = current_user.posts.new(post_params)
  #   respond_to do |format|
  #     if @post.save
  #       format.html { redirect_to @post, notice: 'Post was successfully created.' }
  #       format.json { render :show, status: :created, location: @post }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @post.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        # format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.html { redirect_to root_path, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /posts/:id/like
  def like
    @post.toggle_like(current_user)
    redirect_back(fallback_location: root_path)
  end

  def hashtags
    @tag = Tag.find_by(name: params[:name])
    @posts = @tag.posts.order(created_at: :desc)
  end

  def search
    if params.has_key?(:keyword)
      @keyword = params[:keyword]

      if @keyword.present?
        @searched_users = User.where('name like ?', "%#{@keyword}%").order(created_at: :desc)
        @searched_books = Book.where('title like ?', "%#{@keyword}%").order(created_at: :desc)
        @searched_posts = Post.where('content like ?', "%#{@keyword}%").order(created_at: :desc)
      end

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      #params.require(:post).permit(:content)
      #params.require(:post).permit(:content, :book_id)
      params.require(:post).permit(:content)
    end
end
