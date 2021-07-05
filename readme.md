
### Example apps

These are small example apps written in Elm to be run on the Lamdera platform.

They are a basic starting point for folks who would prefer to learn by reading code.

Check out the [Lamdera quick overview](https://dashboard.lamdera.app/) for the basic concepts.


#### [counter](counter) <small>(115 lines of code)</small>

The canonical Elm counter app converted to a global multi-user counter – it's almost a bootstrap Lamdera project.

#### [chat](chat) <small>(180 lines of code)</small>

A simple single-room global chat server


### Try it out

Locally with the [`lamdera` binary](https://dashboard.lamdera.app/docs/download):

```
git clone git@github.com:lamdera/example-apps.git
cd example-apps/counter
lamdera reset
lamdera live
```


### Other example apps:

#### [Lamdera Realworld](https://github.com/supermario/lamdera-realworld) <small>(2926 lines of code)</small>

A full frontend/backend Realworld app implementation using Lamdera primitives, extended from the [frontend-only elm-spa Realworld](https://github.com/ryannhg/elm-spa-realworld) app.
