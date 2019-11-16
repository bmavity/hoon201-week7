import React, { Component } from 'react';

const styles = {
  sticky: {
    lineHeight: '15px',
    padding: '3px 0',
    position: 'relative',
    listStyleType: 'none',
  },
  completeButton: {
    cursor: 'pointer',
    position: 'absolute',
    right: '0',
    top: '0',
  }
}

export default class Sticky extends Component {
  setComplete(id) {
    api.action('stickies', 'json', { 'complete-sticky': { id, } })
  }

  render() {
    const { id, content, } = this.props

    return (
      <li style={styles.sticky}>
        {content}

        <div
          style={styles.completeButton}
          onClick={() => this.setComplete(id)}
        >
          ✔
        </div>
      </li>
    )
  }
}