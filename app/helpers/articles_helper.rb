module ArticlesHelper
    def upvote_label(article, user)
        label_text = if user.voted_up_on? article
                        "Unlike"
                    else
                        "Like"
                    end
        tag.span do 
            "#{article.cached_votes_up} #{label_text} "
        end

    end

    def downvote_label(article, user)
        label_text = if user.voted_down_on? article
                        "Unlike"
                    else
                        "Dislike"
                    end
        tag.span do 
            "#{article.cached_votes_down} #{label_text} "
        end
    end

    def upvote_label_styles(article, user)
        if user.voted_up_on? article
            "background-color: #00b300"
        end
    end
    def downvote_label_styles(article, user)
        if user.voted_down_on? article
            "background-color: #ff0000"
        end
    end
end
