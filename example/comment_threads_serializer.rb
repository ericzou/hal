class CommentThreadsSerializer

  def initialize(comment_threads)
    @comment_threads = comment_threads;
  end

  def links
    relations :comment_threads do |comment_thread|
      link href: comment_thread_url
    end
  end

  def embedded
    resources :commend_threads, each_serializer: CommentThreadSerializer
  end
end

class CommentThreadSerializer
  attributes :subject_type, :title

  def initialize(comment_thread)
    @comment_thread = comment_thread
    @item = @comment_thread.item
    @author = @comment_thread.author
    @comments = @comment_thread.comments
  end

  def links
    relation :item, href: item_url(@item)
    relation :author, href: user_url(@author)
    relation :comments do |comment|
      link href: comment_url(comment)
    end
  end
end
