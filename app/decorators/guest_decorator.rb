class GuestDecorator < SimpleDelegator
  def initialize(guest)
    @guest = guest
    super
  end

  def flag_icon
    # TODO: extract flag icon from guest data... ie: country they entered
    ["flag-icon-fr", "flag-icon-gb", "flag-icon-us"].sample
  end

  def gravatar_url(size = 36)
    "#{gravatar_base_url}/#{gravatar_id}.png?"\
      "s=#{size}&d=#{CGI.escape(gravatar_fallback_image_url)}"
  end

  private

  def gravatar_base_url
    "http://gravatar.com/avatar"
  end

  def gravatar_fallback_image_url
    # TODO: use real fallback img
    "https://www.biography.com/.image/ar_1:1%2Cc_fill%2Ccs_srgb%2Cg_face%2Cq_auto:good%2Cw_300/MTU0OTkwNDUxOTQ5MDUzNDQ3/kanye-west-attends-the-christian-dior-show-as-part-of-the-paris-fashion-week-womenswear-fall-winter-2015-2016-on-march-6-2015-in-paris-france-photo-by-dominique-charriau-wireimage-square.jpg"
  end

  def gravatar_id
    Digest::MD5.hexdigest(@guest.email).downcase
  end
end
