# my-last-cv
A simple gem to generate beautiful CV from a markdown file

## How to use it?
```bash
bundle add my-last-cv
bundle install
bundle exec my_last_cv sample/cv.md output/cv.pdf
```

## Custom fonts
By default, the gem looks for fonts in `./fonts` of the calling project.
You can override this with `Style.new(fonts_dir: "/path/to/fonts")`
or `MY_LAST_CV_FONTS_DIR=/path/to/fonts`.
