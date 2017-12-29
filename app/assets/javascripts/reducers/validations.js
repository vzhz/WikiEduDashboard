import { RECEIVE_COURSE_CHECK, SET_VALID, SET_INVALID } from "../constants";

const stateFromValidations = (_validations) => {
  const errors = [];
  Object.keys(_validations).forEach(key => {
    if (_validations[key] && _validations[key].valid === false) {
      errors.push(_validations[key].message);
    }
  });
  const isValid = errors.length === 0;
  return { validations: _validations, errors, isValid };
};

const initialState = stateFromValidations({});

const newInvalidState = (state, key, message) => {
  const newValidations = { ...state.validations };
  newValidations[key] = { valid: false, message };
  return stateFromValidations(newValidations);
};

const newValidState = (state, key) => {
  const newValidations = { ...state.validations };
  newValidations[key] = { valid: true };
  return stateFromValidations(newValidations);
};

export default function validations(state = initialState, action) {
  switch (action.type) {
    case RECEIVE_COURSE_CHECK: {
      const exists = !!action.data.course_exists;
      if (exists) {
        return newInvalidState(state, 'exists', I18n.t('courses.creator.already_exists'));
      }
      return newValidState(state, 'exists');
    }
    case SET_VALID:
      return newValidState(state, action.key);
    case SET_INVALID:
      return newInvalidState(state, action.key, action.message);
    default:
      return state;
  }
}
