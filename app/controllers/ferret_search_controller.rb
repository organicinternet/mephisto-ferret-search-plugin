class FerretSearchController < ApplicationController
  layout nil
  session :off
  unloadable

  def search
    @section = params[:s].nil? ? nil : site.sections.detect { |s| s.path == params[:s] }
    joins          = nil
    conditions     = ['(published_at IS NOT NULL AND published_at <= :now)', 
                     { :now => Time.now.utc }]
    if @section
      conditions.first << ' AND (assigned_sections.section_id = :section)'
      conditions.last[:section] = @section.id
    end

    @articles = site.articles.find_with_ferret(
                                       params[:q],
                                       :conditions => conditions, :order => 'published_at DESC',
                                       :include => [:user, :sections],
                                       :per_page => site.articles_per_page, :page => params[:page]
                                       )
    
    render_liquid_template_for(:search, 'articles'      => @articles,
                                        'previous_page' => paged_search_url_for(@articles.previous_page),
                                        'next_page'     => paged_search_url_for(@articles.next_page),
                                        'search_string' => CGI::escapeHTML(params[:q]),
                                        'search_count'  => @articles.total_entries,
                                        'section'       => @section)
    @skip_caching = true
  end
  
  protected
  
  def paged_search_url_for(page)
    page ? "/ferret_search?q=#{CGI::escapeHTML(params[:q])}#{%(&amp;page=#{CGI::escapeHTML(page.to_s)})}" : ''
  end
  
end