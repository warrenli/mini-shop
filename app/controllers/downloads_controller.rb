class DownloadsController < CurrentUserController
  def index
    criteria = params[:search]
    @search = DownloadLink.by_user(@user).new_search(criteria)
    @download_links, @download_links_count = @search.all, @search.count
  end

  def show
    download_link = DownloadLink.by_user(@user).by_token(params[:token]).first
    if download_link
      dl = download_link.download
      filename = dl.data_file_name
      filetype = dl.data_content_type
      path= "#{RAILS_ROOT}/assets/downloads/datas/#{dl.id}/#{filename}"

      send_file("#{path}",
                :filename     =>  "#{filename}",
                :type         =>  '#{filetype}',
                :disposition  =>  'attachment',
                :streaming    =>  'true',
                :buffer_size  =>  4096
      )

      download_link.update_attributes( :last_download_at => Time.now.utc )
    else
      render :nothing => true
    end
  end

  def sub_layout
    'user_dashboard'
  end
end
