class SiteController < ApplicationController

  def index
  end

  def how_it_works
  end

  def why_social_endorsement
  end

  def technology
  end

  def clients
  end

  def pricing
    if request.post?
      missing = []
      missing << "Name" if params[:name].blank?
      missing << "Email" if params[:email].blank?
      missing << "Content" if params[:what].blank?
      if missing.any?
        flash.now[:alert] = missing.join(", ") << " cannot be empty."
      else
        ContactMailer.contact(params[:name], params[:email], params[:what]).deliver
        flash.now[:notice] = "Email was sent to admin. Thank you for contact."
      end
    end
  end

end

