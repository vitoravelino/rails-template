# frozen_string_literal: true

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require "tmpdir"

    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git(clone: [
      "--quiet",
      "https://github.com/vitoravelino/rails-template.git",
      tempdir,
    ]).map(&:shellescape).join(" ")

    branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1]
    Dir.chdir(tempdir) { git(checkout: branch) } if branch
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def docker_compose?
  ENV.fetch("COMPOSE", false)
end

def redis?
  ENV.fetch("REDIS", false)
end

def mongo?
  ENV.fetch("MONGO", false)
end

def mysql?
  ARGV.include?("--database=mysql") || ARGV.include?("mysql")
end

def postgres?
  ARGV.include?("--database=postgresql") || ARGV.include?("postgresql")
end

def add_gems
  # gem("modular_routes", path: "../modular_routes")

  # dependency managment
  gem("dry-system")

  # use case
  gem("u-case")

  # misc
  gem("rack-cors")
  gem("rails-i18n")

  # cache / background
  if redis?
    gem("connection_pool")
    gem("hiredis")
    gem("redis")
  end

  # auth
  gem("bcrypt")
  gem("jwt")
  gem("omniauth-google-oauth2")
  gem("omniauth-facebook")
  gem("omniauth-github")
  gem("omniauth-twitter")

  # persistence
  gem("mongoid") if mongo?

  # authorization
  gem("pundit")

  gem_group(:development) do
    gem("bullet")

    gem("bundler-audit", require: false)
    gem("brakeman", require: false)
    gem("rubocop", require: false)
    gem("rubocop-performance", require: false)
    gem("rubocop-shopify", require: false)
    gem("rubycritic", require: false)
  end

  gem_group(:development, :test) do
    gem("awesome_print")
    gem("coverband", require: false)
  end

  gem_group(:test) do
    gem("ffaker")
    gem("timecop")

    gem("simplecov", require: false)
  end
end

def add_redis_store
  return unless redis?

  config = <<~RUBY
    # Redis cache store
    redis_config = Rails.application.config_for(:redis)

    config.cache_store = :redis_cache_store, {
      host: redis_config.host,
      password: redis_config.password,
      port: redis_config.port,
      pool_size: redis_config.pool,
      pool_timeout: redis_config.timeout,
    }
  RUBY

  environment(config, env: :production)
  environment(config, env: :development)
end

def add_production_configs
  environment("config.force_ssl = true", env: :production)
end

def add_dry_test_helper
  content = <<~RUBY

    require "dry/container/stub"

    #{app_const_base}::Container.enable_stubs!
  RUBY

  insert_into_file("test/test_helper.rb", content, after: 'require "rails/test_help"')
end

def add_ssl
  ssl_config = <<~RUBY
    # SSL
    config.force_ssl = true

  RUBY

  environment(ssl_config, env: :production)
  # environment(ssl_config, env: :development)
end

def add_rubycritic_rake_task
  require_content = <<~RUBY
    require "rubycritic/rake_task"

  RUBY

  task_content = <<~RUBY
    RubyCritic::RakeTask.new

  RUBY

  insert_into_file("Rakefile", require_content, before: "require_relative")
  insert_into_file("Rakefile", task_content, before: "Rails.application.load_tasks")
end

def add_bullet_config
  content = <<~RUBY
    config.after_initialize do
      Bullet.enable = true
    end

  RUBY

  environment(content, env: :development)
end

def copy_files
  template("config/initializers/dry_system.rb.tt")
  template("docker-compose.yml.tt") if docker_compose?

  copy_file(".rubocop.yml")
  copy_file("Dockerfile") if docker_compose?

  directory("config", force: true)
  directory("lib")
end

def show_notes
  say
  say("* Organize Gemfile")
  say("* Remove default cache strategy from 'config/environment/development.rb'") if redis?
  say
  say("To get started with your app:")
  say
  say("  cd #{app_name}/")
  say("  bundle")
  say("  rails db:create db:migrate")
  say("  rails g mongoid:config") if mongo?
end

def add_i18n_config
  content = <<~RUBY
    # i18n
    config.i18n.available_locales = :en

  RUBY

  environment(content)
end

self.options = options.merge(skip_active_record: mongo?)

add_template_repository_to_source_path

after_bundle do
  add_gems
  add_redis_store
  add_ssl
  add_dry_test_helper
  add_rubycritic_rake_task
  add_i18n_config
  add_bullet_config

  copy_files

  show_notes
end

def run_bundle; end
