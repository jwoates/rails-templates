  def fb_connection
    FbGraph::Auth.new(FB_APP_ID,FB_APP_SECRET)
  end

  def fb_parse_data(fb)
    sr = params[:signed_request] if params[:signed_request]
    if sr
      fb.from_signed_request(sr)
    elsif request.cookies
      fb.from_cookie(request.cookies)
    else
      nil
    end
  end

  def fb_get_authorization(fb,redirect_uri,scope)
    fb.client.redirect_uri = redirect_uri
    fb.client.authorization_uri(scope)
  end

  def fb_user(fb)
    if fb.authorized?
     user = FbGraph::User.me(fb.access_token)
     user.fetch
    else
     nil
    end
  end

  def like(sr)
    like = sr.data[:page][:liked]
  end
