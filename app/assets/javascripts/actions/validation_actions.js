import McFly from 'mcfly';
const Flux = new McFly();
import API from '../utils/api.js';
import { SET_INVALID, SET_VALID, RECEIVE_COURSE_CHECK, API_FAIL } from "../constants";

export const setInvalidKey = (key, message) => {
  return { type: SET_INVALID, key, message };
};

export const setValidKey = (key) => {
  return { type: SET_VALID, key };
};

export const checkSlugAvailability = (slug) => dispatch => {
  return API.fetch(slug, 'check')
    .then(resp => dispatch({ type: RECEIVE_COURSE_CHECK, data: resp }))
    .catch(resp => dispatch({ type: API_FAIL, data: resp }));
};

const ValidationActions = Flux.createActions({
  initialize(key, message) {
    return {
      actionType: 'INITIALIZE',
      data: {
        key,
        message
      }
    };
  },

  setValid(key, quiet = false) {
    return {
      actionType: 'SET_VALID',
      data: {
        key,
        quiet
      }
    };
  },

  setInvalid(key, message, quiet = false) {
    return {
      actionType: 'SET_INVALID',
      data: {
        key,
        message,
        quiet
      }
    };
  }
});

export default ValidationActions;
