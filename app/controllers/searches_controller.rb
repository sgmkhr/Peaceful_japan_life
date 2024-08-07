class SearchesController < ApplicationController
  def new
    @prefectures = RecommendPlacePost.prefectures
  end

  def search
    @model = params[:model]
    @method = params[:method]
    @content = params[:content]
    if @model == "user"
      @role = params[:role]
      @records = User.search_for(@content, @method, @role)
      @records = Kaminari.paginate_array(@records).page(params[:page])
    elsif @model == "recommend_place_post"
      @subject = params[:subject]
      @prefecture = params[:prefecture]
      @records = RecommendPlacePost.search_for(@content, @method, @prefecture, @subject)
      @records = Kaminari.paginate_array(@records).page(params[:page])
    else
      @records = Tag.search_posts_for(@content)
      @records = Kaminari.paginate_array(@records).page(params[:page])
    end
  end
end
