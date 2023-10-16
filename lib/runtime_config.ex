defmodule Bonfire.RuntimeConfig do
  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  alias Bonfire.Ecto.Acts, as: Ecto

  @page_act_opts [on: :page, attrs: :page_attrs]
  @section_act_opts [on: :section, attrs: :section_attrs]

  @doc """
  NOTE: you can override this default config in your app's runtime.exs, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs` line
  """
  def config do
    import Config

    delete_object = [
      # Create a changeset for deletion
      {Bonfire.Social.Acts.Objects.Delete, on: :object},

      # mark for deletion
      {Ecto.Delete,
       on: :object,
       delete_extra_associations: [
         :post_content,
         :tagged,
         :media
       ]},

      # Now we have a short critical section
      Ecto.Begin,
      # Run our deletes
      Ecto.Work,
      Ecto.Commit,
      # Enqueue for un-indexing by meilisearch
      {Bonfire.Search.Acts.Queue, on: :object},

      # Oban would rather we put these here than in the transaction
      # above because it knows better than us, obviously.
      # Prepare for federation and add to deletion queue (oban).
      {Bonfire.Social.Acts.Federate, on: :object}
    ]

    config :bonfire_social, Bonfire.Social.Follows, []

    config :bonfire_social, Bonfire.Social.Posts,
      epics: [
        publish: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          Bonfire.Social.Acts.Posts.Publish,
          # These steps are run in parallel
          [
            # with a sanitised body and tags extracted,
            {Bonfire.Social.Acts.PostContents, on: :post},

            # assign a caretaker,
            {Bonfire.Me.Acts.Caretaker, on: :post},

            # record the creator,
            {Bonfire.Me.Acts.Creator, on: :post}
          ],
          # These steps are run in parallel and require the outputs of the previous ones
          [
            # possibly fetch contents of URLs (depends on PostContents),
            {Bonfire.Files.Acts.URLPreviews, on: :post},

            # possibly occurring in a thread,
            {Bonfire.Social.Acts.Threaded, on: :post},

            # with extracted tags/mentions fully hooked up (depends on PostContents),
            {Bonfire.Tags.Acts.Tag, on: :post},

            # maybe set as sensitive,
            {Bonfire.Social.Acts.Sensitivity, on: :post}
          ],
          # These steps are run in parallel and require the outputs of the previous ones
          [
            # possibly with uploaded/linked media (optionally depends on URLPreviews),
            {Bonfire.Files.Acts.AttachMedia, on: :post},

            # with appropriate boundaries established (depends on PostContents and Threaded),
            {Bonfire.Boundaries.Acts.SetBoundaries, on: :post},

            # summarised by an activity (possibly appearing in feeds),
            {Bonfire.Social.Acts.Activity, on: :post}
            # {Bonfire.Social.Acts.Feeds,       on: :post},
          ],

          # Now we have a short critical section
          Ecto.Begin,
          # Run our inserts
          Ecto.Work,
          Ecto.Commit,

          # Preload data (TODO: move this to seperate act) & Publish live feed updates via (in-memory) PubSub
          {Bonfire.Social.Acts.LivePush, on: :post},

          # These steps are run in parallel, and could casually in the background (without waiting for their result, but still notifying the user of there's an error)
          [
            # Enqueue for indexing by meilisearch
            {Bonfire.Search.Acts.Queue, on: :post},

            # Oban would rather we put these here than in the transaction above
            # Prepare JSON for federation and add to queue (oban).
            {Bonfire.Social.Acts.Federate, on: :post}
          ],

          # Once the activity/object exists (including in AP db), we can apply these side effects
          {Bonfire.Tags.Acts.AutoBoost, on: :post}
        ],
        delete: delete_object
      ]

    # Generic deletion
    config :bonfire_social, Bonfire.Social.Objects,
      epics: [
        delete: delete_object
      ]

    ## PAGES
    config :bonfire_pages, Bonfire.Pages,
      epics: [
        create: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Page.Create, @page_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @page_act_opts},
          # a caretaker,
          {Bonfire.Me.Acts.Caretaker, @page_act_opts},
          # and a creator,
          {Bonfire.Me.Acts.Creator, @page_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @page_act_opts},
          # possibly with uploaded files,
          {Bonfire.Files.Acts.AttachMedia, @page_act_opts},
          # with extracted tags fully hooked up,
          {Bonfire.Tags.Acts.Tag, @page_act_opts},
          # and the appropriate boundaries established,
          {Bonfire.Boundaries.Acts.SetBoundaries, @page_act_opts},
          # summarised by an activity?
          # {Bonfire.Social.Acts.Activity, @page_act_opts},
          # {Bonfire.Social.Acts.Feeds,       @page_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          Ecto.Begin,
          # Run our inserts
          Ecto.Work,
          Ecto.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {Bonfire.Social.Acts.LivePush, @page_act_opts},
          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @page_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {Bonfire.Social.Acts.Federate, @page_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Tags.Acts.AutoBoost, @page_act_opts}
        ]
      ]

    config :bonfire_pages, Bonfire.Pages.Sections,
      epics: [
        upsert: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Section.Upsert, @section_act_opts},
          # with a sanitised body and tags extracted,
          {Bonfire.Social.Acts.PostContents, @section_act_opts},
          # a caretaker,
          {Bonfire.Me.Acts.Caretaker, @section_act_opts},
          # and a creator,
          {Bonfire.Me.Acts.Creator, @section_act_opts},
          # and possibly fetch contents of URLs,
          {Bonfire.Files.Acts.URLPreviews, @section_act_opts},
          # possibly with uploaded files,
          {Bonfire.Files.Acts.AttachMedia, @section_act_opts},
          # with extracted tags fully hooked up,
          {Bonfire.Tags.Acts.Tag, @section_act_opts},
          # and the appropriate boundaries established,
          {Bonfire.Boundaries.Acts.SetBoundaries, @section_act_opts},
          # summarised by an activity?
          # {Bonfire.Social.Acts.Activity, @section_act_opts},
          # {Bonfire.Social.Acts.Feeds,       @section_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          Ecto.Begin,
          # Run our inserts
          Ecto.Work,
          Ecto.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {LivePush, @section_act_opts},
          # Enqueue for indexing by meilisearch
          {Bonfire.Search.Acts.Queue, @section_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {Bonfire.Social.Acts.Federate, @section_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Tags.Acts.AutoBoost, @section_act_opts}
        ]
      ]
  end

  def finch_pool_config() do
    %{
      :default => [size: 42, count: 2],
      "https://icons.duckduckgo.com" => [
        conn_opts: [transport_opts: [size: 8, timeout: 3_000]]
      ],
      "https://www.google.com/s2/favicons" => [
        conn_opts: [transport_opts: [size: 8, timeout: 3_000]]
      ]
    }
    |> maybe_add_sentry_pool()
  end

  def maybe_add_sentry_pool(pool_config) do
    case Code.ensure_loaded?(Sentry.Config) and Sentry.Config.dsn() do
      dsn when is_binary(dsn) ->
        Map.put(pool_config, dsn, size: 50)

      _ ->
        pool_config
    end
  end
end
