if defined?(Footnotes)
    Footnotes::Filter.multiple_notes = false
    Footnotes::Filter.notes =[:cookies, :env, :filters, :general, :log, :params, :queries, :routes, :session]
end


# Enable Footnote
#
# if defined?(Footnotes)
#    Footnotes::Filter.prefix = 'gedit://open?url=file://%s&line=%d&column=%d'
# end

# Footnotes::Filter.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log, :general]

# ALL  Footnotes::Filter.notes =[:components, :controller, :cookies, :env, :files, :filters, :general, :javascripts, :layout, :log, :params, :queries, :routes, :session, :stylesheets, :view]

