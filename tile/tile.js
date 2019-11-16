import React, { Component } from 'react';
import classnames from 'classnames';
import _ from 'lodash';

import StickiesDisplay from './StickiesDisplay'


export default class stickiesTile extends Component {
  state = {
    isCreatingNewSticky: false,
    stickyContent: '',
  }

  addSticky(id) {
    api.action('stickies', 'json', { 'add-sticky': { id, content: this.state.stickyContent } })
    this.setState(s => ({
      ...s,
      isCreatingNewSticky: false,
      stickyContent: '',
    }))
  }

  hideCreationPanel() {
    this.setState(s => ({
      ...s,
      isCreatingNewSticky: false,
    }))
  }

  showCreationPanel() {
    this.setState(s => ({
      ...s,
      isCreatingNewSticky: true,
    }))
  }

  updateContent(evt) {
    const stickyContent = evt.target.value
    this.setState(s => ({
      ...s,
      stickyContent,
    }))
  }

  render() {
    const stickies = this.props.data
    const stickiesArr = Object.values(stickies || {})
    const highestId = stickiesArr.reduce((maxId, sticky) => sticky.id > maxId ? sticky.id : maxId, 0)

    return (
      <div className="w-100 h-100 relative" style={{ background: '#1a1a1a' }}>
        <p className="gray label-regular b" style={{ left: 8, top: 4 }}>Stickies</p>
        
        <div className="fl w-100 pa2">
        {this.state.isCreatingNewSticky ? (
          <div>
            <div>
              <label className="white" htmlFor="sticky-content">Sticky Content</label>
              <input
                id="sticky-content"
                name="sticky-content"
                value={this.state.stickyContent}
                onChange={evt => this.updateContent(evt)}
              />
            </div>

            <button onClick={() => this.hideCreationPanel()}>Cancel</button>
            <button onClick={() => this.addSticky(highestId + 1)}>Save</button>
          </div>
        ) : (
          <div>
            <div className="p2 white">
              <StickiesDisplay stickies={stickies} />
            </div>

            <button onClick={() => this.showCreationPanel()}>Create New Sticky</button>
          </div>
        )}
        </div>
      </div>
    );
  }

}

window.stickiesTile = stickiesTile;
