import React, { Component } from 'react';

import Sticky from './Sticky'

const styles = {
  stickiesList: {
    margin: 0,
    padding: 0,
  }
}

export default class StickiesDisplay extends Component {
  render() {
    const { stickies } = this.props
    const stickiesArr = Object.values(stickies)
    
    return stickiesArr.length ? (
      <ul style={styles.stickiesList}>
        {stickiesArr
          .filter(sticky => !sticky['is-complete'])
          .map(sticky => (<Sticky key={sticky.id} {... sticky} />))}
      </ul>
    ) : (
      <div className="white">No Stickies have been created yet</div>
    )
  }
}